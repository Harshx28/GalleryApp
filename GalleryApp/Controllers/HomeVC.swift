//
//  HomeVC.swift
//  GalleryApp
//

import UIKit
internal import CoreData

class HomeVC: UIViewController {

    // MARK: - Outlets
    @IBOutlet weak var colImages: UICollectionView!
    @IBOutlet weak var vwProfile: UIView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var imgPerson: UIImageView!

    // MARK: - Data
    var apiImages: [PicsumImage] = []
    var cachedImages: [CachedImage] = []

    private var currentPage = 1
    private let limit = 10

    private var isLoading = false
    private var isOfflineMode = false

    // 🔒 Pagination lock
    private var pendingImageLoads = 0
    private var isPageFullyLoaded = true

    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        observeNetwork()
    }

    deinit {
        print("‼️ deinit HomeVC")
    }

    // MARK: - Setup
    private func setupUI() {

        let nib = UINib(nibName: "CellImages", bundle: nil)
        colImages.register(nib, forCellWithReuseIdentifier: "CellImages")

        colImages.delegate = self
        colImages.dataSource = self
        colImages.prefetchDataSource = self

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(profileTapped))
        vwProfile.addGestureRecognizer(tapGesture)
        
        self.imgPerson.layer.cornerRadius = self.imgPerson.frame.height / 2
                self.imgPerson.clipsToBounds = true

        let user = UserSession.shared
        self.lblName.text = user.fullName
        self.imgPerson.setImageFromURL(user.profileImage ?? "")
    }

    @objc private func profileTapped() {
        let vc = storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as! ProfileVC
        navigationController?.pushViewController(vc, animated: true)
    }

    // MARK: - Network Observer
    private func observeNetwork() {
        NetworkMonitor.shared.start { isConnected in
            DispatchQueue.main.async {
                let newOffline = !isConnected

                if self.isOfflineMode != newOffline {
                    self.resetState()
                }

                self.isOfflineMode = newOffline
                newOffline ? self.loadOffline() : self.loadOnline()
            }
        }
    }

    private func resetState() {
        currentPage = 1
        apiImages.removeAll()
        cachedImages.removeAll()
        colImages.setContentOffset(.zero, animated: false)
        isPageFullyLoaded = true
    }

    // MARK: - Online Loading (CONTROLLED)
    private func loadOnline() {

        guard !isOfflineMode,
              !isLoading,
              isPageFullyLoaded else { return }

        isLoading = true
        isPageFullyLoaded = false

        let pageSnapshot = currentPage

        PicsumService.shared.fetchImages(page: pageSnapshot, limit: limit) { images in
            DispatchQueue.main.async {

                let existingIDs = Set(self.apiImages.map { $0.id })
                let unique = images.filter { !existingIDs.contains($0.id) }

                guard !unique.isEmpty else {
                    self.isLoading = false
                    self.isPageFullyLoaded = true
                    return
                }

                self.pendingImageLoads = unique.count
                self.apiImages.append(contentsOf: unique)

                self.colImages.performBatchUpdates {
                    let start = self.apiImages.count - unique.count
                    let indexPaths = (start..<self.apiImages.count)
                        .map { IndexPath(item: $0, section: 0) }
                    self.colImages.insertItems(at: indexPaths)
                }

                self.currentPage += 1
                self.isLoading = false

                // Cache asynchronously
                self.saveToCoreData(unique)
            }
        }
    }

    // MARK: - Offline Loading
    private func loadOffline() {
        let context = PersistenceController.shared.container.viewContext
        let request: NSFetchRequest<CachedImage> = CachedImage.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "id", ascending: true)]
        cachedImages = (try? context.fetch(request)) ?? []
        colImages.reloadData()
    }

    // MARK: - Core Data Cache
    private func saveToCoreData(_ images: [PicsumImage]) {

        let context = PersistenceController.shared.container.newBackgroundContext()

        let imagesToCache = Array(images.prefix(limit))
        let group = DispatchGroup()

        var existingIDs = Set<String>()
        context.performAndWait {
            let fetch: NSFetchRequest<CachedImage> = CachedImage.fetchRequest()
            if let results = try? context.fetch(fetch) {
                existingIDs = Set(results.compactMap { $0.id })
            }
        }

        for image in imagesToCache {
            guard !existingIDs.contains(image.id),
                  let url = URL(string: image.download_url) else { continue }

            group.enter()
            URLSession.shared.dataTask(with: url) { data, _, _ in
                defer { group.leave() }

                guard let data = data else { return }

                context.perform {
                    let cached = CachedImage(context: context)
                    cached.id = image.id
                    cached.imageData = data
                }
            }.resume()
        }

        group.notify(queue: .global(qos: .utility)) {
            context.perform {
                if context.hasChanges {
                    try? context.save()
                }
            }
        }
    }
}

// MARK: - CollectionView
extension HomeVC: UICollectionViewDelegate,
                  UICollectionViewDataSource,
                  UICollectionViewDelegateFlowLayout {

    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        isOfflineMode ? cachedImages.count : apiImages.count
    }

    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell(
            withReuseIdentifier: "CellImages",
            for: indexPath
        ) as! CellImages

        cell.imageLoadCompletion = { [weak self] in
            guard let self = self else { return }
            self.pendingImageLoads -= 1
            if self.pendingImageLoads <= 0 {
                self.isPageFullyLoaded = true
            }
        }

        if isOfflineMode {
            if let data = cachedImages[indexPath.item].imageData {
                cell.configure(with: data)
            }
        } else {
            cell.configure(with: apiImages[indexPath.item].download_url)
        }

        return cell
    }

    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        guard !isOfflineMode else { return }

        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let threshold: CGFloat = 160

        if contentHeight > 0,
           offsetY > contentHeight - scrollView.frame.height - threshold {
            loadOnline()
        }
    }

    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {

        let width = (collectionView.frame.width - 10) / 2
        return CGSize(width: width, height: 150)
    }
}

// MARK: - Prefetch
extension HomeVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView,
                        prefetchItemsAt indexPaths: [IndexPath]) {

        guard !isOfflineMode else { return }

        if let maxItem = indexPaths.map({ $0.item }).max(),
           maxItem > apiImages.count - 4 {
            loadOnline()
        }
    }
}

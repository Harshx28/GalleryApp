//
//  CellImages.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import UIKit

class CellImages: UICollectionViewCell {

    @IBOutlet weak var vwBg: UIView!
    @IBOutlet weak var imgWallpaper: UIImageView!

    // MARK: - Cache (shared across cells)
    private static let imageCache: NSCache<NSString, UIImage> = {
        let cache = NSCache<NSString, UIImage>()
        cache.countLimit = 100 // Limit number of images
        cache.totalCostLimit = 50 * 1024 * 1024 // 50 MB limit
        return cache
    }()

    private var shimmerView: ShimmerView?
    private var currentImageKey: NSString?
    private var currentTask: URLSessionDataTask?

    // Pagination callback
    var imageLoadCompletion: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imgWallpaper.layer.cornerRadius = 8
        imgWallpaper.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        currentTask?.cancel()
        currentTask = nil
        imgWallpaper.image = nil
        currentImageKey = nil
        imageLoadCompletion = nil
        hideShimmer()
    }

    // MARK: - Offline (CoreData)
    func configure(with imageData: Data, imageId: String? = nil) {
        // Use image ID if available, otherwise fallback to hash (less ideal but backward compatible)
        let keyString = imageId ?? "offline_\(imageData.hashValue)"
        let key = NSString(string: keyString)
        currentImageKey = key

        // Check cache first
        if let cachedImage = Self.imageCache.object(forKey: key) {
            imgWallpaper.image = cachedImage
            imageLoadCompletion?()
            return
        }

        guard let image = UIImage(data: imageData) else {
            imageLoadCompletion?()
            return
        }

        Self.imageCache.setObject(image, forKey: key)
        imgWallpaper.image = image
        imageLoadCompletion?()
    }

    // MARK: - Online
    func configure(with urlString: String) {
        // Cancel any previous task
        currentTask?.cancel()
        
        let key = NSString(string: urlString)
        currentImageKey = key

        // Check cache first
        if let cachedImage = Self.imageCache.object(forKey: key) {
            imgWallpaper.image = cachedImage
            imageLoadCompletion?()
            return
        }

        // Show shimmer for first-time load
        showShimmer()

        guard let url = URL(string: urlString) else {
            hideShimmer()
            imageLoadCompletion?()
            return
        }

        currentTask = URLSession.shared.dataTask(with: url) { [weak self] data, response, error in
            DispatchQueue.main.async {
                guard let self = self,
                      self.currentImageKey == key else {
                    return
                }

                defer {
                    self.hideShimmer()
                    self.imageLoadCompletion?()
                }

                // Check for errors or cancellation
                if let error = error as NSError?,
                   error.code == NSURLErrorCancelled {
                    return
                }

                guard let data = data,
                      let image = UIImage(data: data) else {
                    return
                }

                // Verify we're still showing the same image
                guard self.currentImageKey == key else {
                    return
                }

                Self.imageCache.setObject(image, forKey: key)
                self.imgWallpaper.image = image
            }
        }
        currentTask?.resume()
    }

    // MARK: - Shimmer
    private func showShimmer() {
        guard shimmerView == nil else { return }

        let shimmer = ShimmerView(frame: contentView.bounds)
        shimmer.layer.cornerRadius = 10
        shimmer.clipsToBounds = true
        contentView.addSubview(shimmer)
        shimmer.startShimmer()
        shimmerView = shimmer
    }

    private func hideShimmer() {
        shimmerView?.stopShimmer()
        shimmerView?.removeFromSuperview()
        shimmerView = nil
    }
}

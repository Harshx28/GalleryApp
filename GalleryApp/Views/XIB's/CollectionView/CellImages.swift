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
    private static let imageCache = NSCache<NSString, UIImage>()

    private var shimmerView: ShimmerView?
    private var currentImageKey: NSString?

    // Pagination callback
    var imageLoadCompletion: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        imgWallpaper.layer.cornerRadius = 8
        imgWallpaper.clipsToBounds = true
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imgWallpaper.image = nil
        currentImageKey = nil
        imageLoadCompletion = nil
        hideShimmer()
    }

    // MARK: - Offline (CoreData)
    func configure(with imageData: Data) {

        let key = NSString(string: "\(imageData.hashValue)")
        currentImageKey = key

        
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

        let key = NSString(string: urlString)
        currentImageKey = key

        
        if let cachedImage = Self.imageCache.object(forKey: key) {
            imgWallpaper.image = cachedImage
            imageLoadCompletion?()
            return
        }

        // ❌ Show shimmer ONLY for first-time load
        showShimmer()

        guard let url = URL(string: urlString) else {
            hideShimmer()
            imageLoadCompletion?()
            return
        }

        URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
            DispatchQueue.main.async {

                guard let self = self else { return }

                defer {
                    self.hideShimmer()
                    self.imageLoadCompletion?()
                }

                guard
                    let data = data,
                    let image = UIImage(data: data),
                    self.currentImageKey == key
                else {
                    return
                }

                
                Self.imageCache.setObject(image, forKey: key)
                self.imgWallpaper.image = image
            }
        }.resume()
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

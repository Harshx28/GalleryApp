//
//  UIImageView+Extension.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 2025-12-31.
//

import UIKit

extension UIImageView {

    func setImageFromURL(_ urlString: String, placeholder: UIImage? = nil) {
        self.image = placeholder

        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            guard let data = data,
                  let image = UIImage(data: data) else { return }

            DispatchQueue.main.async {
                self.image = image
            }
        }.resume()
    }
}

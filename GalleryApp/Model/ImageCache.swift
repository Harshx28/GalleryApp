//
//  ImageCache.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation
import UIKit

final class ImageCache {
    static let shared = NSCache<NSString, UIImage>()
}

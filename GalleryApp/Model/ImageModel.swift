//
//  ImageModel.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation

struct PicsumImage: Codable {
    let id: String
    let author: String
    let width: Int
    let height: Int
    let download_url: String
}

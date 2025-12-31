//
//  PicsumService.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation

final class PicsumService {

    static let shared = PicsumService()
    private init() {}

    func fetchImages(page: Int,
                     limit: Int,
                     completion: @escaping ([PicsumImage]) -> Void) {

        let urlString = "https://picsum.photos/v2/list?page=\(page)&limit=\(limit)"
        guard let url = URL(string: urlString) else { return }

        URLSession.shared.dataTask(with: url) { data, _, _ in
            if let data = data,
               let images = try? JSONDecoder().decode([PicsumImage].self, from: data) {
                DispatchQueue.main.async {
                    completion(images)
                }
            }
        }.resume()
    }
}

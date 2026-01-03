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
        guard let url = URL(string: urlString) else {
            DispatchQueue.main.async {
                completion([])
            }
            return
        }

        URLSession.shared.dataTask(with: url) { data, response, error in
            // Handle errors
            if let error = error {
                print("PicsumService error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            // Handle HTTP errors
            if let httpResponse = response as? HTTPURLResponse,
               httpResponse.statusCode != 200 {
                print("PicsumService HTTP error: \(httpResponse.statusCode)")
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            // Parse data
            guard let data = data else {
                DispatchQueue.main.async {
                    completion([])
                }
                return
            }

            do {
                let images = try JSONDecoder().decode([PicsumImage].self, from: data)
                DispatchQueue.main.async {
                    completion(images)
                }
            } catch {
                print("PicsumService decode error: \(error.localizedDescription)")
                DispatchQueue.main.async {
                    completion([])
                }
            }
        }.resume()
    }
}

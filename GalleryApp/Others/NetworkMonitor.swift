//
//  NetworkMonitor.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation
import Network

class NetworkMonitor {

    static let shared = NetworkMonitor()
        private let monitor = NWPathMonitor()
        private let queue = DispatchQueue(label: "NetworkMonitor")

        func start(status: @escaping (Bool) -> Void) {
            monitor.pathUpdateHandler = { path in
                DispatchQueue.main.async {
                    status(path.status == .satisfied)
                }
            }
            monitor.start(queue: queue)
        }
}

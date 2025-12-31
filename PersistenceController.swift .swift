//
//  PersistenceController.swift .swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//

import Foundation
internal import CoreData

struct PersistenceController {

    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init() {
        container = NSPersistentContainer(name: "GalleryApp")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("CoreData error \(error)")
            }
        }
    }
}

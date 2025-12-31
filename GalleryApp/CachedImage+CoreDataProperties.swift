//
//  CachedImage+CoreDataProperties.swift
//  GalleryApp
//
//  Created by Harsh Sangani on 31/12/25.
//
//

import Foundation
internal import CoreData


extension CachedImage {

    @nonobjc class func fetchRequest() -> NSFetchRequest<CachedImage> {
        return NSFetchRequest<CachedImage>(entityName: "CachedImage")
    }

    @NSManaged public var id: String?
    @NSManaged public var imageData: Data?
    @NSManaged public var author: String?

}

extension CachedImage : Identifiable {

}

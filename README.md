
# Picsum Gallery (iOS)

A sample iOS app that displays a grid of images from the Picsum service with smooth pagination, offline caching using Core Data, and basic network reachability handling. The app demonstrates UICollectionView with prefetching, background Core Data writes, and graceful online/offline switching.

## Features

- Infinite scrolling grid of images (2-column layout)
- Throttled network requests to avoid over-fetching
- Data prefetching for smooth scrolling
- Offline mode backed by Core Data image caching
- Automatic online/offline switching using a network monitor
- Batch updates for efficient collection view updates

## Architecture Overview

- HomeVC: The main view controller that manages the collection view, pagination, and online/offline state.
- PicsumService: A shared service responsible for fetching metadata from the Picsum API (e.g., `fetchImages(page:limit:)`).
- PersistenceController: A Core Data stack wrapper that exposes `container`, `viewContext`, and `newBackgroundContext()` for background saves.
- CachedImage (Core Data): An entity storing image `id` and binary `imageData` for offline use.
- NetworkMonitor: A shared reachability helper that notifies when connectivity changes.
- CellImages: A custom UICollectionViewCell that can configure itself from either a `PicsumImage` (online) or a `CachedImage` (offline).

## How It Works

1. On launch, the app starts monitoring network connectivity. The UI switches between online and offline modes accordingly.
2. In online mode, images are fetched page-by-page from the Picsum service. Duplicate items are filtered out.
3. Each successful fetch is persisted to Core Data on a background context. If possible, the app also downloads and stores image data for offline use.
4. In offline mode, items are loaded from Core Data and displayed immediately.
5. Pagination is triggered as the user scrolls near the end of the list or when prefetch requests indicate upcoming cells.
6. Network requests are throttled to 1 request per second to avoid excessive calls.

## Requirements

- Xcode 15 or later
- iOS 15 or later (UIKit)
- Swift 5.8+

## Setup & Run

1. Open the `.xcodeproj` or `.xcworkspace` in Xcode.
2. Ensure the Core Data model includes an entity named `CachedImage` with attributes:
   - `id` (String)
   - `imageData` (Binary Data, Optional)
3. Provide implementations for the following components if not already present:
   - `PicsumService` with `fetchImages(page:limit:completion:)`
   - `PersistenceController` with a working NSPersistentContainer
   - `NetworkMonitor` that reports connectivity changes via a callback
   - `CellImages` cell with a `configure(with:)` overload for `PicsumImage` and `CachedImage`
4. Build and run on a device or simulator.

## Key Files

- HomeVC.swift: Manages the collection view, pagination, and mode switching.
- PicsumService.swift: Networking for Picsum API.
- PersistenceController.swift: Core Data stack and helpers.
- CachedImage+CoreDataClass.swift / CachedImage+CoreDataProperties.swift: Core Data model classes.
- NetworkMonitor.swift: Reachability helper.
- CellImages.xib / CellImages.swift: Collection view cell UI and logic.

## Notes on Performance & UX

- Throttling: The call to `CACurrentMediaTime()` ensures no more than one fetch per second to prevent spamming the API.
- Batch Updates: `performBatchUpdates` improves UI performance when appending items.
- Prefetching: `UICollectionViewDataSourcePrefetching` triggers early loads to keep scrolling smooth.
- Background Saves: Core Data writes occur on a background context to avoid blocking the main thread.

## Error Handling

- Networking errors can be surfaced via lightweight UI (e.g., a banner or toast). The sample currently no-ops on failure but is easily extendable.

## Privacy & Networking

- The app fetches public images from the Picsum service. No personal data is collected or transmitted.

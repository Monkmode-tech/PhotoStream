import Foundation
import SwiftUI

@MainActor
class PhotoGridViewModel: ObservableObject {
    @Published var photos: [Photo] = []
    @Published var isLoadingPage = false
    private var currentPage = 1
    private var canLoadMore = true
    private let perPage = 10
    
    func loadInitialPhotos() async {
        guard photos.isEmpty else { return }
        await loadMorePhotos()
    }
    
    func loadMoreIfNeeded(currentPhoto: Photo) {
        guard let last = photos.last, last.id == currentPhoto.id else { return }
        Task {
            await loadMorePhotos()
        }
    }
    
    private func loadMorePhotos() async {
        guard !isLoadingPage && canLoadMore else { return }
        isLoadingPage = true
        do {
            // Try changing the query to "nature" for testing
            let response = try await PhotoService.shared.fetchSearchPhotos(query: "nature", page: currentPage, perPage: perPage)
            if response.photos.isEmpty {
                print("No photos returned from API for query: nature, page: \(currentPage)")
                canLoadMore = false
            } else {
                photos.append(contentsOf: response.photos)
                currentPage += 1
            }
        } catch {
            print("Failed to load photos: \(error.localizedDescription)")
            if let urlError = error as? URLError {
                print("URLError code: \(urlError.code)")
            }
            canLoadMore = false
        }
        isLoadingPage = false
    }
}

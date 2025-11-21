import SwiftUI

fileprivate let cache = PersistentImageCache()

struct CachedAsyncImage: View {
    let url: URL?
    let content: (Image) -> AnyView
    let placeholder: () -> AnyView
    @State private var uiImage: UIImage?
    @State private var isLoading = false
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                content(Image(uiImage: uiImage))
            } else if isLoading {
                placeholder()
            } else {
                placeholder()
                    .onAppear {
                        if !isLoading && uiImage == nil {
                            isLoading = true
                            Task {
                                await loadImage()
                            }
                        }
                    }
            }
        }
    }
    
    private func cacheKey(for url: URL) -> String {
        url.absoluteString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? url.absoluteString
    }
    
    private func loadImage() async {
        guard let url = url, uiImage == nil else { isLoading = false; return }
        if let cached = await cache.image(forKey: cacheKey(for: url)) {
            await MainActor.run { self.uiImage = cached }
            isLoading = false
            return
        }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: data) {
                await cache.setImage(image, forKey: cacheKey(for: url))
                await MainActor.run { self.uiImage = image }
            } else {
                print("Failed to create UIImage from data for URL: \(url)")
            }
        } catch {
            print("Failed to load image from URL: \(url), error: \(error)")
        }
        isLoading = false
    }
}

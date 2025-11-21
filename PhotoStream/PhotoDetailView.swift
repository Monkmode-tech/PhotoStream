import SwiftUI

struct PhotoDetailView: View {
    let photo: Photo
    @State private var isDownloading = false
    @State private var downloadProgress: Double = 0
    @State private var errorMessage: String?
    @State private var shareURL: URL?
    @State private var isSharing = false
    @State private var downloadComplete = false
    
    var body: some View {
        VStack(spacing: 16) {
            PhotoImageView(
                url: URL(string: photo.src.large2x),
                aspectRatio: .fit,
                height: nil,
                cornerRadius: 12,
                backgroundColor: Color("SurfaceColor")
            )
            .frame(maxHeight: 400)
            Text(photo.photographer)
                .font(.headline)
            DownloadStatusView(
                isDownloading: isDownloading,
                downloadProgress: downloadProgress,
                downloadComplete: downloadComplete,
                errorMessage: errorMessage
            )
            DownloadButtonView(isDownloading: isDownloading, action: exportToFiles)
        }
        .padding()
        .background(Color("BackgroundColor").ignoresSafeArea())
        .navigationTitle(photo.alt ?? "Photo Detail")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $isSharing, onDismiss: { downloadComplete = false }) {
            if let shareURL = shareURL {
                ShareSheet(activityItems: [shareURL])
            }
        }
    }
    
    func downloadImageWithProgress(from url: URL) async throws -> (URL, Double) {
        let (bytes, response) = try await URLSession.shared.bytes(for: URLRequest(url: url))
        guard let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        let totalBytes = httpResponse.expectedContentLength > 0 ? httpResponse.expectedContentLength : 1
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        var downloadedBytes: Int64 = 0
        var data = Data()
        for try await byte in bytes {
            data.append(byte)
            downloadedBytes += 1
            downloadProgress = Double(downloadedBytes) / Double(totalBytes)
        }
        try data.write(to: fileURL)
        return (fileURL, downloadProgress)
    }
    
    func exportToFiles() {
        guard let url = URL(string: photo.src.original) else {
            errorMessage = "Invalid image URL."
            return
        }
        let fileURL = FileManager.default.temporaryDirectory.appendingPathComponent(url.lastPathComponent)
        if FileManager.default.fileExists(atPath: fileURL.path) {
            shareURL = fileURL
            isSharing = true
            downloadComplete = true
        } else {
            isDownloading = true
            errorMessage = nil
            downloadComplete = false
            Task {
                do {
                    let (localURL, _) = try await downloadImageWithProgress(from: url)
                    shareURL = localURL
                    isSharing = true
                    downloadComplete = true
                } catch {
                    errorMessage = error.localizedDescription
                }
                isDownloading = false
            }
        }
    }
}

struct PhotoDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let samplePhoto = Photo(
            id: 1,
            width: 4000,
            height: 3000,
            url: "https://www.pexels.com/photo/123/",
            photographer: "Jane Doe",
            photographer_url: "https://www.pexels.com/@janedoe",
            photographer_id: 123,
            avg_color: "#CCCCCC",
            src: PhotoSource(
                original: "https://images.pexels.com/photos/123/original.jpg",
                large2x: "https://images.pexels.com/photos/123/large2x.jpg",
                large: "https://images.pexels.com/photos/123/large.jpg",
                medium: "https://images.pexels.com/photos/123/medium.jpg",
                small: "https://images.pexels.com/photos/123/small.jpg",
                portrait: "https://images.pexels.com/photos/123/portrait.jpg",
                landscape: "https://images.pexels.com/photos/123/landscape.jpg",
                tiny: "https://images.pexels.com/photos/123/tiny.jpg"
            ),
            liked: false,
            alt: "Sample Photo"
        )
        NavigationView {
            PhotoDetailView(photo: samplePhoto)
        }
    }
}

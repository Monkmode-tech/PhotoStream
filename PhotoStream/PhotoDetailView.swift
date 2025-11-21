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
            Button(action: exportToFiles) {
                Label("Download Original", systemImage: "arrow.down.circle")
            }
            .disabled(isDownloading)
            .buttonStyle(.borderedProminent)
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

struct DownloadStatusView: View {
    var isDownloading: Bool
    var downloadProgress: Double
    var downloadComplete: Bool
    var errorMessage: String?
    
    var body: some View {
        Group {
            if isDownloading {
                ProgressView(value: downloadProgress)
                    .progressViewStyle(LinearProgressViewStyle())
                Text("Downloading...")
            } else if downloadComplete {
                Text("Download complete!")
                    .foregroundColor(Color("AppPrimaryColor"))
            } else if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }
        }
    }
}

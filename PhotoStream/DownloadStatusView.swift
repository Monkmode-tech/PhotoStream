import SwiftUI

struct DownloadStatusView: View {
    let isDownloading: Bool
    let downloadProgress: Double
    let downloadComplete: Bool
    let errorMessage: String?
    
    var body: some View {
        Group {
            if isDownloading {
                VStack(spacing: 4) {
                    ProgressView(value: downloadProgress)
                        .progressViewStyle(LinearProgressViewStyle())
                    Text("Downloading...")
                }
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

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 16) {
        DownloadStatusView(isDownloading: true, downloadProgress: 0.5, downloadComplete: false, errorMessage: nil)
        DownloadStatusView(isDownloading: false, downloadProgress: 1.0, downloadComplete: true, errorMessage: nil)
        DownloadStatusView(isDownloading: false, downloadProgress: 0.0, downloadComplete: false, errorMessage: "Error occurred")
    }
    .padding()
}

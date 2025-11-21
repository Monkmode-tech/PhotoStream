import SwiftUI

struct DownloadButtonView: View {
    let isDownloading: Bool
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Label("Download Original", systemImage: "arrow.down.circle")
        }
        .disabled(isDownloading)
        .buttonStyle(.borderedProminent)
    }
}

#Preview(traits: .sizeThatFitsLayout) {
    VStack(spacing: 16) {
        DownloadButtonView(isDownloading: false, action: {})
        DownloadButtonView(isDownloading: true, action: {})
    }
    .padding()
}

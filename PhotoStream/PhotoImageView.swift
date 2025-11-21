import SwiftUI

struct PhotoImageView: View {
    let url: URL?
    let aspectRatio: ContentMode
    let height: CGFloat?
    let cornerRadius: CGFloat
    let backgroundColor: Color
    
    init(url: URL?, aspectRatio: ContentMode = .fill, height: CGFloat? = nil, cornerRadius: CGFloat = 10, backgroundColor: Color = Color("SurfaceColor")) {
        self.url = url
        self.aspectRatio = aspectRatio
        self.height = height
        self.cornerRadius = cornerRadius
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        CachedAsyncImage(url: url) { image in
            AnyView(
                image
                    .resizable()
                    .aspectRatio(contentMode: aspectRatio)
                    .ifLet(height) { view, height in
                        view.frame(height: height)
                    }
                    .clipped()
                    .background(backgroundColor)
                    .cornerRadius(cornerRadius)
            )
        } placeholder: {
            AnyView(ProgressView())
        }
    }
}

// Helper extension for conditional modifier
extension View {
    @ViewBuilder
    func ifLet<T, Content: View>(_ value: T?, transform: (Self, T) -> Content) -> some View {
        if let value = value {
            transform(self, value)
        } else {
            self
        }
    }
}

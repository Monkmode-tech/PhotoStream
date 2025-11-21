import SwiftUI

struct PhotoGridView: View {
    @StateObject private var viewModel = PhotoGridViewModel()
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 16) {
                    ForEach(viewModel.photos) { photo in
                        NavigationLink(destination: PhotoDetailView(photo: photo)) {
                            PhotoImageView(
                                url: URL(string: photo.src.portrait),
                                aspectRatio: .fill,
                                height: 200,
                                cornerRadius: 10,
                                backgroundColor: Color("SurfaceColor")
                            )
                        }
                        .onAppear {
                            viewModel.loadMoreIfNeeded(currentPhoto: photo)
                        }
                    }
                }
                .padding()
                if viewModel.isLoadingPage {
                    ProgressView()
                        .padding()
                }
            }
            .background(Color("BackgroundColor").ignoresSafeArea())
            .navigationTitle("PhotoStream")
            .task {
                await viewModel.loadInitialPhotos()
            }
        }
    }
}

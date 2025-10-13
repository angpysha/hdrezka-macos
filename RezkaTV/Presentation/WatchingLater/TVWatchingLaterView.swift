import Defaults
import SwiftUI

struct TVWatchingLaterView: View {
    @State private var viewModel = WatchingLaterViewModel()
    @Default(.isLoggedIn) private var isLoggedIn
    
    var body: some View {
        Group {
            if isLoggedIn {
                ScrollView {
                    if let movies = viewModel.state.data, !movies.isEmpty {
                        LazyVGrid(columns: [
                            GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 50)
                        ], spacing: 50) {
                            ForEach(movies) { movieWatchLater in
                                let movie = MovieSimple(
                                    movieId: movieWatchLater.watchLaterId,
                                    name: movieWatchLater.name,
                                    details: movieWatchLater.details,
                                    poster: movieWatchLater.cover
                                )
                                NavigationLink(value: movie) {
                                    TVCardView(movie: movie, width: 300)
                                }
                                .buttonStyle(.plain)
                            }
                        }
                        .padding(.horizontal, 90)
                        .padding(.vertical, 60)
                    } else if viewModel.state == .loading {
                        ProgressView()
                            .scaleEffect(2.0)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if let error = viewModel.state.error {
                        VStack(spacing: 40) {
                            Image(systemName: "exclamationmark.triangle")
                                .font(.system(size: 80))
                                .foregroundStyle(.secondary)
                            
                            Text(error.localizedDescription)
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                            
                            Button {
                                viewModel.load()
                            } label: {
                                Text("key.retry")
                                    .font(.system(size: 28))
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(90)
                    } else {
                        VStack(spacing: 40) {
                            Image(systemName: "clock")
                                .font(.system(size: 80))
                                .foregroundStyle(.secondary)
                            
                            Text("key.watching_later.empty")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .padding(90)
                    }
                }
            } else {
                VStack(spacing: 40) {
                    Image(systemName: "person.fill.questionmark")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("key.sign_in.required")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                    
                    Button {
                        AppState.shared.isSignInPresented = true
                    } label: {
                        Text("key.sign_in")
                            .font(.system(size: 28))
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .task(id: isLoggedIn) {
            if isLoggedIn, viewModel.state.data == nil {
                viewModel.load()
            }
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }
}


import SwiftUI

struct TVListView: View {
    @State private var viewModel: ListViewModel
    
    init(list: MovieList) {
        _viewModel = State(initialValue: ListViewModel(list: list))
    }
    
    init(country: MovieCountry) {
        _viewModel = State(initialValue: ListViewModel(country: country))
    }
    
    init(genre: MovieGenre) {
        _viewModel = State(initialValue: ListViewModel(genre: genre))
    }
    
    init(collection: MoviesCollection) {
        _viewModel = State(initialValue: ListViewModel(collection: collection))
    }
    
    var body: some View {
        ScrollView {
            if let movies = viewModel.state.data, !movies.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 50)
                ], spacing: 50) {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie) {
                            TVCardView(movie: movie, width: 300)
                        }
                        .buttonStyle(.plain)
                        .onAppear {
                            // Підвантаження при досягненні кінця
                            if movie == movies.last {
                                viewModel.loadMore()
                            }
                        }
                    }
                }
                .padding(.horizontal, 90)
                .padding(.vertical, 60)
                
                // Індикатор підвантаження
                if viewModel.paginationState == .loading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .padding(40)
                }
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
            } else if let movies = viewModel.state.data, movies.isEmpty {
                VStack(spacing: 40) {
                    Image(systemName: "film")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text("key.empty")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .padding(90)
            }
        }
        .task {
            if viewModel.state.data == nil {
                viewModel.load()
            }
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }
}


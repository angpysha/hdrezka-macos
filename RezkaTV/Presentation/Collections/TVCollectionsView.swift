import SwiftUI

struct TVCollectionsView: View {
    @State private var viewModel = CollectionsViewModel()

    var body: some View {
        ScrollView {
            if let collections = viewModel.state.data, !collections.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 400, maximum: 500), spacing: 40),
                ], spacing: 40) {
                    ForEach(collections) { collection in
                        NavigationLink(value: collection) {
                            VStack(alignment: .leading, spacing: 20) {
                                // Превью зображення або іконка
                                ZStack {
                                    Rectangle()
                                        .fill(
                                            LinearGradient(
                                                colors: [.orange, .red],
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing,
                                            ),
                                        )

                                    Image(systemName: "rectangle.stack")
                                        .font(.system(size: 60))
                                        .foregroundStyle(.white)
                                }
                                .frame(height: 200)
                                .cornerRadius(20)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(collection.name)
                                        .font(.system(size: 32, weight: .semibold))
                                        .lineLimit(2)
                                }
                            }
                            .padding(30)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(20)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(90)
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
            }
        }
        .task {
            if viewModel.state.data == nil {
                viewModel.load()
            }
        }
        .navigationDestination(for: MoviesCollection.self) { collection in
            TVCollectionDetailsView(collection: collection)
        }
    }
}

struct TVCollectionDetailsView: View {
    let collection: MoviesCollection
    @State private var selectedFilter: CollectionFilter = .latest
    @State private var movies: [MovieSimple] = []
    @State private var isLoading = false

    var body: some View {
        VStack(spacing: 0) {
            // Фільтри
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 30) {
                    ForEach(CollectionFilter.allCases, id: \.self) { filter in
                        Button {
                            selectedFilter = filter
                            loadMovies()
                        } label: {
                            Text(filter.title)
                                .font(.system(size: 28))
                                .padding(.horizontal, 40)
                                .padding(.vertical, 20)
                                .background(selectedFilter == filter ? Color.white : Color.gray.opacity(0.3))
                                .foregroundStyle(selectedFilter == filter ? .black : .white)
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 90)
                .padding(.vertical, 40)
            }

            // Список фільмів
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 50),
                ], spacing: 50) {
                    ForEach(movies) { movie in
                        NavigationLink(value: movie) {
                            TVCardView(movie: movie, width: 300)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 90)
                .padding(.vertical, 60)
            }
        }
        .navigationTitle(collection.name)
        .task {
            loadMovies()
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }

    private func loadMovies() {
        // Тут буде логіка завантаження фільмів з колекції
        isLoading = true
        // TODO: Implement collection movies loading
        isLoading = false
    }
}

enum CollectionFilter: CaseIterable {
    case latest
    case popular
    case soon
    case watchingNow

    var title: String {
        switch self {
        case .latest: String(localized: "key.latest")
        case .popular: String(localized: "key.popular")
        case .soon: String(localized: "key.soon")
        case .watchingNow: String(localized: "key.watching_now")
        }
    }
}

import SwiftUI

struct TVListView: View {
    @Environment(\.dismiss) private var dismiss
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
        TVBackHandler(content: contentView, onMenu: {
            dismiss()
        })
    }
    
    private var contentView: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 40) {
                // Заголовок з інформацією про категорію
                HStack(alignment: .center, spacing: 30) {
                    VStack(alignment: .leading, spacing: 10) {
                        Text(viewModel.title)
                            .font(.system(size: 48, weight: .bold))

                        if let movies = viewModel.state.data {
                            Text("\(movies.count)")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Spacer()
                }
                .padding(.horizontal, 90)
                .padding(.top, 60)

                if let movies = viewModel.state.data, !movies.isEmpty {
                    LazyVGrid(columns: [
                        GridItem(.adaptive(minimum: 300, maximum: 350), spacing: 50),
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
                    .padding(.bottom, 60)

                    // Індикатор підвантаження
                    if viewModel.paginationState == .loading {
                        ProgressView()
                            .scaleEffect(1.5)
                            .padding(40)
                    }
                } else if viewModel.state == .loading {
                    ProgressView()
                        .scaleEffect(2.0)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 100)
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
                                .padding(.horizontal, 50)
                                .padding(.vertical, 20)
                                .background(Color.accentColor)
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                } else if let movies = viewModel.state.data, movies.isEmpty {
                    VStack(spacing: 40) {
                        Image(systemName: "film")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text("key.empty")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 100)
                }
            }
        }
        .navigationTitle(viewModel.title)
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 10) {
                        Image(systemName: "chevron.left")
                        Text(String(localized: "key.categories"))
                    }
                    .font(.system(size: 24))
                }
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

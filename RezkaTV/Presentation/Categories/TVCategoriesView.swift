import SwiftUI

struct TVCategoriesView: View {
    @State private var viewModel = CategoriesViewModel()

    var body: some View {
        ScrollView {
            if let categories = viewModel.state.data, !categories.isEmpty {
                LazyVGrid(columns: [
                    GridItem(.adaptive(minimum: 400, maximum: 500), spacing: 40),
                ], spacing: 40) {
                    ForEach(categories) { type in
                        // Створюємо MovieGenre з typeId для навігації
                        let genre = MovieGenre(name: type.name, genreId: type.typeId)
                        
                        NavigationLink(value: genre) {
                            VStack(alignment: .leading, spacing: 20) {
                                // Іконка категорії
                                Image(systemName: categoryIcon(for: type))
                                    .font(.system(size: 60))
                                    .foregroundStyle(.white)
                                    .frame(width: 120, height: 120)
                                    .background(
                                        LinearGradient(
                                            colors: [.blue, .purple],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing,
                                        ),
                                    )
                                    .cornerRadius(20)

                                VStack(alignment: .leading, spacing: 8) {
                                    Text(type.name)
                                        .font(.system(size: 32, weight: .semibold))
                                }
                            }
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(40)
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
        .navigationDestination(for: MovieGenre.self) { genre in
            TVListView(genre: genre)
        }
    }

    private func categoryIcon(for type: MovieType) -> String {
        // Підбираємо іконку залежно від типу категорії
        let titleLower = type.name.lowercased()
        if titleLower.contains("фільм") || titleLower.contains("film") {
            return "film"
        } else if titleLower.contains("серіал") || titleLower.contains("series") {
            return "tv"
        } else if titleLower.contains("мультфільм") || titleLower.contains("cartoon") {
            return "sparkles"
        } else if titleLower.contains("аніме") || titleLower.contains("anime") {
            return "star"
        } else {
            return "folder"
        }
    }
}

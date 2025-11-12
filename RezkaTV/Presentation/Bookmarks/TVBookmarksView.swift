import Defaults
import SwiftUI

struct TVBookmarksView: View {
    @State private var viewModel = BookmarksViewModel()
    @Default(.isLoggedIn) private var isLoggedIn

    var body: some View {
        Group {
            if isLoggedIn {
                if let bookmarks = viewModel.bookmarksState.data, !bookmarks.isEmpty {
                    ScrollView {
                        LazyVStack(alignment: .leading, spacing: 50) {
                            ForEach(bookmarks) { category in
                                VStack(alignment: .leading, spacing: 30) {
                                    // Заголовок категорії
                                    HStack {
                                        Text(category.name)
                                            .font(.system(size: 42, weight: .bold))

                                        Spacer()

                                        Text("\(category.count)")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.secondary)
                                    }
                                    .padding(.horizontal, 90)

                                    // Список фільмів - треба завантажити окремо
                                    Text("key.tap_to_view")
                                        .font(.system(size: 24))
                                        .foregroundStyle(.secondary)
                                        .padding(.horizontal, 90)
                                }
                            }
                        }
                        .padding(.vertical, 60)
                    }
                } else if viewModel.bookmarksState == .loading {
                    ProgressView()
                        .scaleEffect(2.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let error = viewModel.bookmarksState.error {
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
                        Image(systemName: "bookmark")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text("key.bookmarks.empty")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(90)
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
                        // Відкрити екран входу
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
            if isLoggedIn, viewModel.bookmarksState.data == nil {
                viewModel.load()
            }
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }
}

import Defaults
import SwiftUI

struct TVBookmarksView: View {
    @State private var viewModel = BookmarksViewModel()
    @Default(.isLoggedIn) private var isLoggedIn

    var body: some View {
        Group {
            if isLoggedIn {
                // Подібно до iOS версії - показуємо список категорій та фільми
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
                                    .tvSafeArea()

                                    // Список фільмів для цієї категорії
                                    Button {
                                        viewModel.selectedBookmark = category.bookmarkId
                                    } label: {
                                        Text("key.tap_to_view")
                                            .font(.system(size: 24))
                                            .foregroundStyle(.secondary)
                                    }
                                    .tvSafeArea()
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
                            viewModel.getBookmarks(reset: true)
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
                // Показуємо екран авторизації
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
        .onChange(of: viewModel.selectedBookmark) {
            if viewModel.selectedBookmark != nil {
                viewModel.load()
            }
        }
        .task(id: isLoggedIn) {
            if isLoggedIn, viewModel.bookmarksState.data == nil {
                viewModel.getBookmarks()
            }
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }
}

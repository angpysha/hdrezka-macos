import Defaults
import SwiftUI

struct TVBookmarksView: View {
    @State private var viewModel = BookmarksViewModel()
    @Default(.isLoggedIn) private var isLoggedIn

    var body: some View {
        Group {
            if isLoggedIn {
                if let bookmarks = viewModel.bookmarksState.data, !bookmarks.isEmpty {
                    // Якщо вибрана категорія - показуємо фільми
                    if let selectedBookmark = viewModel.selectedBookmark,
                       let selectedCategory = bookmarks.first(where: { $0.bookmarkId == selectedBookmark }) {
                        ScrollView {
                            VStack(alignment: .leading, spacing: 40) {
                                // Заголовок з кнопкою "Назад"
                                HStack(alignment: .center, spacing: 30) {
                                    Button {
                                        viewModel.selectedBookmark = nil
                                    } label: {
                                        HStack(spacing: 15) {
                                            Image(systemName: "chevron.left")
                                                .font(.system(size: 32))
                                            Text(String(localized: "key.bookmarks"))
                                                .font(.system(size: 32, weight: .semibold))
                                        }
                                        .foregroundStyle(.white)
                                        .padding(.horizontal, 40)
                                        .padding(.vertical, 20)
                                        .background(Color.gray.opacity(0.5))
                                        .cornerRadius(15)
                                    }
                                    .buttonStyle(.plain)

                                    VStack(alignment: .leading, spacing: 10) {
                                        Text(selectedCategory.name)
                                            .font(.system(size: 48, weight: .bold))

                                        Text("\(selectedCategory.count)")
                                            .font(.system(size: 28))
                                            .foregroundStyle(.secondary)
                                    }

                                    Spacer()
                                }
                                .padding(.horizontal, 90)
                                .padding(.top, 60)

                                if let movies = viewModel.bookmarkState.data, !movies.isEmpty {
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
                                    .padding(.bottom, 60)
                                } else if viewModel.bookmarkState == .loading {
                                    ProgressView()
                                        .scaleEffect(2.0)
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 100)
                                } else if let error = viewModel.bookmarkState.error {
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
                                } else {
                                    VStack(spacing: 40) {
                                        Image(systemName: "bookmark")
                                            .font(.system(size: 80))
                                            .foregroundStyle(.secondary)

                                        Text("key.bookmarks.empty")
                                            .font(.system(size: 32))
                                            .foregroundStyle(.secondary)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 100)
                                }
                            }
                        }
                    } else {
                        // Показуємо список категорій
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

                                        // Кнопка для вибору категорії
                                        Button {
                                            viewModel.selectedBookmark = category.bookmarkId
                                        } label: {
                                            HStack(spacing: 20) {
                                                Text("key.see_all")
                                                    .font(.system(size: 32, weight: .semibold))
                                                    .foregroundStyle(.white)
                                                Image(systemName: "chevron.right")
                                                    .font(.system(size: 32))
                                                    .foregroundStyle(.white)
                                            }
                                            .padding(.horizontal, 50)
                                            .padding(.vertical, 25)
                                            .background(Color.accentColor)
                                            .cornerRadius(15)
                                        }
                                        .buttonStyle(.plain)
                                        .padding(.horizontal, 90)
                                    }
                                }
                            }
                            .padding(.vertical, 60)
                        }
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
                                .padding(.horizontal, 50)
                                .padding(.vertical, 20)
                                .background(Color.accentColor)
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(90)
                } else {
                    VStack(spacing: 40) {
                        Image(systemName: "bookmark")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text("key.bookmark.empty")
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
                            .background(Color.accentColor)
                            .cornerRadius(15)
                    }
                    .buttonStyle(.plain)
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

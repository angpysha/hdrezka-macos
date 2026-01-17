import Combine
import FactoryKit
import SwiftUI

struct TVBookmarksSheetView: View {
    private let id: String

    @Binding private var isCreateBookmarkPresented: Bool

    init(id: String, isCreateBookmarkPresented: Binding<Bool>) {
        self.id = id
        _isCreateBookmarkPresented = isCreateBookmarkPresented
    }

    @Injected(\.addToBookmarksUseCase) private var addToBookmarksUseCase
    @Injected(\.removeFromBookmarksUseCase) private var removeFromBookmarksUseCase
    @Injected(\.getMovieBookmarksUseCase) private var getMovieBookmarksUseCase

    @State private var subscriptions: Set<AnyCancellable> = []

    @Environment(\.dismiss) private var dismiss

    @State private var state: DataState<[Bookmark]> = .loading

    @State private var error: Error?
    @State private var isErrorPresented: Bool = false

    var body: some View {
        VStack(alignment: .center, spacing: 40) {
            VStack(alignment: .center, spacing: 10) {
                Image(systemName: "bookmark.circle")
                    .font(.system(size: 80))
                    .foregroundStyle(Color.accentColor)

                Text("key.bookmarks")
                    .font(.system(size: 48, weight: .semibold))

                Text("key.bookmarks.description")
                    .font(.system(size: 32))
                    .lineLimit(2, reservesSpace: true)
                    .multilineTextAlignment(.center)
                    .foregroundStyle(.secondary)
            }

            Group {
                if let error = state.error {
                    VStack(alignment: .center, spacing: 20) {
                        Text(error.localizedDescription)
                            .font(.system(size: 28))
                            .lineLimit(nil)
                            .foregroundStyle(.secondary)

                        Button {
                            load(reset: true)
                        } label: {
                            Text("key.retry")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 50)
                                .padding(.vertical, 20)
                                .background(Color.accentColor)
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if var bookmarks = state.data {
                    if bookmarks.isEmpty {
                        VStack(alignment: .center, spacing: 20) {
                            Text("key.bookmark.empty")
                                .font(.system(size: 32))
                                .foregroundStyle(.secondary)

                            Button {
                                load(reset: true)
                            } label: {
                                Text("key.retry")
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.white)
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 20)
                                    .background(Color.accentColor)
                                    .cornerRadius(15)
                            }
                            .buttonStyle(.plain)
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else {
                        ScrollView(.vertical) {
                            VStack(alignment: .center, spacing: 20) {
                                ForEach(bookmarks) { bookmark in
                                    if let index = bookmarks.firstIndex(where: { $0 == bookmark }) {
                                        let isChecked = bookmark.isChecked ?? false

                                        Button {
                                            if let movieId = id.id {
                                                if isChecked {
                                                    removeFromBookmarksUseCase(movies: [movieId], bookmarkUserCategory: bookmark.bookmarkId)
                                                        .receive(on: DispatchQueue.main)
                                                        .sink { completion in
                                                            guard case let .failure(error) = completion else { return }

                                                            self.error = error
                                                            isErrorPresented = true
                                                        } receiveValue: { success in
                                                            if success {
                                                                bookmarks[index] -= 1

                                                                withAnimation(.easeInOut) {
                                                                    state = .data(bookmarks)
                                                                }
                                                            }
                                                        }
                                                        .store(in: &subscriptions)
                                                } else {
                                                    addToBookmarksUseCase(movieId: movieId, bookmarkUserCategory: bookmark.bookmarkId)
                                                        .receive(on: DispatchQueue.main)
                                                        .sink { completion in
                                                            guard case let .failure(error) = completion else { return }

                                                            self.error = error
                                                            isErrorPresented = true
                                                        } receiveValue: { success in
                                                            if success {
                                                                bookmarks[index] += 1

                                                                withAnimation(.easeInOut) {
                                                                    state = .data(bookmarks)
                                                                }
                                                            }
                                                        }
                                                        .store(in: &subscriptions)
                                                }
                                            }
                                        } label: {
                                            HStack(alignment: .center, spacing: 15) {
                                                Image(systemName: isChecked ? "bookmark.fill" : "bookmark")
                                                    .font(.system(size: 36))
                                                    .foregroundStyle(isChecked ? Color.accentColor : .secondary)

                                                Text(verbatim: "\(bookmark.name) (\(bookmark.count))")
                                                    .font(.system(size: 32))
                                                    .monospacedDigit()
                                                    .lineLimit(nil)
                                                    .multilineTextAlignment(.center)
                                                    .foregroundStyle(.primary)
                                            }
                                            .padding(.horizontal, 40)
                                            .padding(.vertical, 25)
                                            .background(isChecked ? Color.accentColor.opacity(0.2) : Color.gray.opacity(0.2))
                                            .cornerRadius(15)
                                        }
                                        .buttonStyle(.plain)
                                        .disabled(id.id == nil)
                                    }
                                }
                            }
                            .padding(20)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 400)
                    }
                } else {
                    ProgressView()
                        .scaleEffect(2.0)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }

            VStack(alignment: .center, spacing: 20) {
                Button {
                    isCreateBookmarkPresented = true
                } label: {
                    Text("key.create")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 60)
                        .background(Color.accentColor)
                        .cornerRadius(15)
                }
                .buttonStyle(.plain)

                Button {
                    dismiss()
                } label: {
                    Text("key.done")
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 400, height: 60)
                        .background(Color.gray.opacity(0.5))
                        .cornerRadius(15)
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 60)
        .padding(.top, 60)
        .padding(.bottom, 40)
        .frame(width: 1000)
        .onAppear {
            load()
        }
        .alert("key.ops", isPresented: $isErrorPresented) {
            Button(role: .cancel) {
                dismiss()
            } label: {
                Text("key.ok")
            }
        } message: {
            if let error {
                Text(error.localizedDescription)
            }
        }
    }

    private func load(reset: Bool = false) {
        if reset {
            withAnimation(.easeInOut) {
                state = .loading
            }
        }

        getMovieBookmarksUseCase(movieId: id)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case let .failure(error) = completion else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) {
                        state = .error(error)
                    }
                }
            } receiveValue: { bookmarks in
                withAnimation(.easeInOut) {
                    state = .data(bookmarks)
                }
            }
            .store(in: &subscriptions)
    }
}

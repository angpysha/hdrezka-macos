import Defaults
import SwiftUI

struct TVSearchView: View {
    @State private var viewModel = SearchViewModel()
    @State private var searchText = ""
    @FocusState private var isSearchFocused: Bool
    @Default(.searchHistoryCache) private var searchHistoryCache

    var body: some View {
        VStack(spacing: 40) {
            // Пошукове поле
            HStack(spacing: 20) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 36))
                    .foregroundStyle(.secondary)

                TextField("key.search", text: $searchText)
                    .font(.system(size: 32))
                    .textFieldStyle(.plain)
                    .focused($isSearchFocused)
                    .onSubmit {
                        performSearch()
                    }

                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                        viewModel.query = ""
                        viewModel.load(force: true)
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .font(.system(size: 32))
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(40)
            .background(Color.gray.opacity(0.2))
            .cornerRadius(20)
            .padding(.horizontal, 90)
            .padding(.top, 40)

            // Результати пошуку або історія
            ScrollView {
                if let movies = viewModel.state.data, !movies.isEmpty {
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
                } else if viewModel.state == .loading {
                    ProgressView()
                        .scaleEffect(2.0)
                        .padding(60)
                } else if let error = viewModel.state.error {
                    VStack(spacing: 30) {
                        Image(systemName: "exclamationmark.triangle")
                            .font(.system(size: 80))
                            .foregroundStyle(.secondary)

                        Text(error.localizedDescription)
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)

                        Button {
                            viewModel.query = searchText
                            viewModel.load(force: true)
                        } label: {
                            Text("key.retry")
                                .font(.system(size: 28))
                        }
                    }
                    .padding(90)
                } else {
                    // Показуємо історію пошуку, якщо поле порожнє
                    if searchText.isEmpty && !searchHistoryCache.recentPhrases.isEmpty {
                        searchHistoryView
                    } else {
                        VStack(spacing: 30) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 80))
                                .foregroundStyle(.secondary)

                            Text("key.search.empty")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                        }
                        .padding(90)
                    }
                }
            }
        }
        .navigationDestination(for: MovieSimple.self) { movie in
            TVDetailsView(movie: movie)
        }
    }
    
    private var searchHistoryView: some View {
        VStack(alignment: .leading, spacing: 30) {
            Text("key.search.recent")
                .font(.system(size: 32, weight: .semibold))
                .padding(.horizontal, 90)
            
            ScrollView {
                VStack(spacing: 20) {
                    ForEach(searchHistoryCache.recentPhrases, id: \.self) { phrase in
                        Button {
                            searchText = phrase
                            performSearch()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "clock.arrow.circlepath")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.secondary)
                                    .frame(width: 30)
                                
                                Text(phrase)
                                    .font(.system(size: 28))
                                    .foregroundStyle(.primary)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                    
                    // Кнопка очищення в кінці списку
                    if !searchHistoryCache.recentPhrases.isEmpty {
                        Button {
                            searchHistoryCache.clear()
                        } label: {
                            HStack(spacing: 16) {
                                Image(systemName: "trash")
                                    .font(.system(size: 24))
                                    .foregroundStyle(.red)
                                    .frame(width: 30)
                                
                                Text("key.clear")
                                    .font(.system(size: 28))
                                    .foregroundStyle(.red)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 30)
                            .padding(.vertical, 20)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(16)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 90)
            }
        }
        .padding(.vertical, 30)
    }
    
    private func performSearch() {
        guard !searchText.isEmpty else { return }
        
        let trimmed = searchText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        
        // Зберігаємо фразу в кеш
        searchHistoryCache.addPhrase(trimmed)
        
        // Виконуємо пошук
        viewModel.query = trimmed
        viewModel.load(force: true)
    }
}

import Defaults
import Kingfisher
import SwiftUI

struct TVDetailsView: View {
    let movie: MovieSimple
    
    @State private var viewModel: DetailsViewModel
    @Default(.isLoggedIn) private var isLoggedIn
    @Environment(AppState.self) private var appState
    
    init(movie: MovieSimple) {
        self.movie = movie
        _viewModel = State(initialValue: DetailsViewModel(id: movie.movieId))
    }
    
    var body: some View {
        ScrollView {
            if let details = viewModel.state.data {
                VStack(alignment: .leading, spacing: 50) {
                    // Верхня частина з постером та інфо
                    HStack(alignment: .top, spacing: 60) {
                        // Постер
                        if let posterURL = URL(string: details.hposter) ?? URL(string: details.poster) {
                            KFImage(posterURL)
                                .placeholder {
                                    Rectangle()
                                        .fill(Color.gray.opacity(0.3))
                                }
                                .resizable()
                                .aspectRatio(2/3, contentMode: .fit)
                                .frame(width: 400)
                                .cornerRadius(20)
                                .shadow(radius: 20)
                        }
                        
                        // Інформація
                        VStack(alignment: .leading, spacing: 30) {
                            Text(details.nameRussian)
                                .font(.system(size: 56, weight: .bold))
                            
                            if let nameOriginal = details.nameOriginal {
                                Text(nameOriginal)
                                    .font(.system(size: 32))
                                    .foregroundStyle(.secondary)
                            }
                            
                            // Рейтинг, рік, тривалість
                            HStack(spacing: 20) {
                                if let rating = details.imdbRating?.value {
                                    HStack(spacing: 8) {
                                        Image(systemName: "star.fill")
                                            .foregroundStyle(.yellow)
                                        Text(String(format: "%.1f", rating))
                                    }
                                    .font(.system(size: 28))
                                }
                                
                                if let year = details.year {
                                    Text(year)
                                        .font(.system(size: 28))
                                        .foregroundStyle(.secondary)
                                }
                            }
                            
                            // Жанри
                            if let genres = details.genres, !genres.isEmpty {
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 15) {
                                        ForEach(genres, id: \.name) { genre in
                                            Text(genre.name)
                                                .font(.system(size: 24))
                                                .padding(.horizontal, 25)
                                                .padding(.vertical, 12)
                                                .background(Color.gray.opacity(0.3))
                                                .cornerRadius(12)
                                        }
                                    }
                                }
                            }
                            
                            // Кнопки дій
                            HStack(spacing: 30) {
                                Button {
                                    // Відкрити плеєр
                                    playMovie()
                                } label: {
                                    HStack(spacing: 15) {
                                        Image(systemName: "play.fill")
                                        Text("key.play")
                                    }
                                    .font(.system(size: 32, weight: .semibold))
                                    .foregroundStyle(.black)
                                    .padding(.horizontal, 50)
                                    .padding(.vertical, 20)
                                    .background(Color.white)
                                    .cornerRadius(15)
                                }
                                .buttonStyle(.plain)
                                
                                if isLoggedIn {
                                Button {
                                    // Додати до закладок - треба реалізувати
                                } label: {
                                        Image(systemName: "bookmark")
                                            .font(.system(size: 32))
                                            .foregroundStyle(.white)
                                            .frame(width: 80, height: 80)
                                            .background(Color.gray.opacity(0.5))
                                            .cornerRadius(15)
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
                            .padding(.top, 20)
                        }
                        
                        Spacer()
                    }
                    .padding(.horizontal, 90)
                    .padding(.top, 60)
                    
                    // Опис
                    VStack(alignment: .leading, spacing: 20) {
                        Text("key.description")
                            .font(.system(size: 38, weight: .semibold))
                        
                        Text(details.description)
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                            .fixedSize(horizontal: false, vertical: true)
                    }
                    .padding(.horizontal, 90)
                    
                    // Схожі фільми
                    if !details.watchAlsoMovies.isEmpty {
                        VStack(alignment: .leading, spacing: 30) {
                            Text("key.similar")
                                .font(.system(size: 38, weight: .semibold))
                                .padding(.horizontal, 90)
                            
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHStack(spacing: 50) {
                                    ForEach(details.watchAlsoMovies) { movie in
                                        NavigationLink(value: movie) {
                                            TVCardView(movie: movie, width: 300)
                                        }
                                        .buttonStyle(.plain)
                                    }
                                }
                                .padding(.horizontal, 90)
                            }
                        }
                    }
                }
                .padding(.bottom, 80)
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
    }
    
    private func playMovie() {
        // Логіка запуску плеєра буде тут
        // Потрібно отримати потік та передати в AVPlayerViewController
        // TODO: Implement player
    }
}


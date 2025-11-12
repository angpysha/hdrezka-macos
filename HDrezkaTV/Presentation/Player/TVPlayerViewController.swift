import AVKit
import Combine
import Defaults
import FactoryKit
import SwiftUI

// ViewModel для плеєра
@Observable
class TVPlayerViewModel {
    @ObservationIgnored @LazyInjected(\.getMovieVideoUseCase) private var getMovieVideoUseCase
    @ObservationIgnored @LazyInjected(\.getSeriesSeasonsUseCase) private var getSeriesSeasonsUseCase

    @ObservationIgnored private var subscriptions: Set<AnyCancellable> = []

    private(set) var isLoading = true
    private(set) var error: String?
    private(set) var player: AVPlayer?

    let details: MovieDetailed

    @ObservationIgnored private var selectedActing: MovieVoiceActing?
    @ObservationIgnored private var selectedSeason: MovieSeason?
    @ObservationIgnored private var selectedEpisode: MovieEpisode?
    @ObservationIgnored private var seasons: [MovieSeason]?

    init(details: MovieDetailed) {
        self.details = details
    }

    func loadVideo() {
        isLoading = true
        error = nil

        // Вибираємо озвучку (перша доступна)
        guard let voiceActing = details.voiceActing?.first else {
            error = "No voice acting available"
            isLoading = false
            return
        }

        selectedActing = voiceActing

        // Якщо серіал - завантажуємо сезони
        if details.series != nil {
            loadSeriesAndPlay(voiceActing: voiceActing)
        } else {
            // Фільм - просто отримуємо відео
            loadVideoStream(voiceActing: voiceActing, season: nil, episode: nil)
        }
    }

    private func loadSeriesAndPlay(voiceActing: MovieVoiceActing) {
        getSeriesSeasonsUseCase(voiceActing: voiceActing)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error.localizedDescription
                    self?.isLoading = false
                }
            } receiveValue: { [weak self] seasons in
                guard let self else { return }

                self.seasons = seasons

                // Вибираємо перший сезон та епізод
                if let firstSeason = seasons.first,
                   let firstEpisode = firstSeason.episodes.first
                {
                    selectedSeason = firstSeason
                    selectedEpisode = firstEpisode
                    loadVideoStream(voiceActing: voiceActing, season: firstSeason, episode: firstEpisode)
                } else {
                    error = "No episodes available"
                    isLoading = false
                }
            }
            .store(in: &subscriptions)
    }

    private func loadVideoStream(voiceActing: MovieVoiceActing, season: MovieSeason?, episode: MovieEpisode?) {
        getMovieVideoUseCase(
            voiceActing: voiceActing,
            season: season,
            episode: episode,
            favs: details.favs,
        )
        .receive(on: DispatchQueue.main)
        .sink { [weak self] completion in
            if case let .failure(error) = completion {
                self?.error = error.localizedDescription
                self?.isLoading = false
            }
        } receiveValue: { [weak self] movieVideo in
            guard let self else { return }

            // Перевіряємо чи потрібен premium
            if movieVideo.needPremium {
                error = String(localized: "key.premium_content")
                isLoading = false
                return
            }

            // Отримуємо URL відео (найкраща якість або вибрана користувачем)
            guard let videoURL = movieVideo.getMaxQuality() else {
                error = "Video URL not available"
                isLoading = false
                return
            }

            // Створюємо AVPlayer
            let player = AVPlayer(url: videoURL)

            // Налаштування плеєра
            player.allowsExternalPlayback = true
            player.usesExternalPlaybackWhileExternalScreenIsActive = true

            // TODO: Відновити позицію відтворення з бази даних
            // TODO: Додати субтитри якщо доступні

            self.player = player
            isLoading = false
        }
        .store(in: &subscriptions)
    }
}

// SwiftUI обгортка для AVPlayerViewController
struct TVPlayerViewController: UIViewControllerRepresentable {
    let player: AVPlayer

    func makeUIViewController(context _: Context) -> AVPlayerViewController {
        let controller = AVPlayerViewController()
        controller.player = player
        controller.allowsPictureInPicturePlayback = true
        return controller
    }

    func updateUIViewController(_ uiViewController: AVPlayerViewController, context _: Context) {
        uiViewController.player = player
    }
}

// View для відтворення
struct TVPlayerView: View {
    let details: MovieDetailed

    @State private var viewModel: TVPlayerViewModel
    @Environment(\.dismiss) private var dismiss

    init(details: MovieDetailed) {
        self.details = details
        _viewModel = State(initialValue: TVPlayerViewModel(details: details))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player = viewModel.player {
                TVPlayerViewController(player: player)
                    .ignoresSafeArea()
                    .onAppear {
                        player.play()
                    }
                    .onDisappear {
                        player.pause()
                    }
            } else if viewModel.isLoading {
                VStack(spacing: 40) {
                    ProgressView()
                        .scaleEffect(2.0)
                        .tint(.white)

                    Text("key.loading")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            } else if let error = viewModel.error {
                VStack(spacing: 40) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 80))
                        .foregroundStyle(.white)

                    Text(error)
                        .font(.system(size: 28))
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 90)

                    Button {
                        dismiss()
                    } label: {
                        Text("key.close")
                            .font(.system(size: 28))
                            .padding(.horizontal, 50)
                            .padding(.vertical, 20)
                    }
                }
            }
        }
        .task {
            viewModel.loadVideo()
        }
    }
}

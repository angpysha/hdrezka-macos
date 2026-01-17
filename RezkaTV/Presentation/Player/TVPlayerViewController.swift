import AVKit
import Combine
import SwiftData
import SwiftUI

struct TVPlayerConfiguration: Identifiable {
    let id = UUID()
    let details: MovieDetailed
    let video: MovieVideo
    let acting: MovieVoiceActing
    let season: MovieSeason?
    let episode: MovieEpisode?
    let quality: String?
}

private struct TVPlayerViewController: UIViewControllerRepresentable {
    let player: AVPlayer
    let onDismiss: () -> Void

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

struct TVPlayerView: View {
    let configuration: TVPlayerConfiguration

    @State private var player: AVPlayer?
    @State private var error: String?
    @State private var timeObserver: Any?
    @State private var cancellables: Set<AnyCancellable> = []
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var playerPositions: [PlayerPosition]

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                TVPlayerViewController(player: player) {
                    saveCurrentPosition(for: player)
                    removeTimeObserver(player: player)
                    dismiss()
                }
                .ignoresSafeArea()
                .onAppear {
                    setupTimeObserver(for: player)
                    player.play()
                }
                .onDisappear {
                    saveCurrentPosition(for: player)
                    removeTimeObserver(player: player)
                    player.pause()
                }
            } else if let error {
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
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(15)
                    }
                }
            } else {
                VStack(spacing: 40) {
                    ProgressView()
                        .scaleEffect(2.0)
                        .tint(.white)

                    Text("key.loading")
                        .font(.system(size: 32))
                        .foregroundStyle(.white)
                }
            }
        }
        .task {
            await setupPlayer()
        }
    }

    private func setupPlayer() async {
        let url: URL? = if let quality = configuration.quality {
            configuration.video.getClosestTo(quality: quality)
        } else {
            configuration.video.getMaxQuality()
        }

        guard let url else {
            await MainActor.run {
                error = String(localized: "key.video_url_not_available")
            }
            return
        }

        let player = AVPlayer(url: url)
        player.allowsExternalPlayback = true
        player.usesExternalPlaybackWhileExternalScreenIsActive = true
        
        // Слухаємо статус плеєра для відновлення позиції
        player.publisher(for: \.status)
            .receive(on: DispatchQueue.main)
            .sink { [weak player] status in
                guard let player = player, status == .readyToPlay else { return }
                restorePosition(for: player)
            }
            .store(in: &cancellables)

        await MainActor.run {
            self.player = player
        }
    }
    
    // MARK: - Position Management
    
    private func restorePosition(for player: AVPlayer) {
        guard let position = findPlayerPosition() else { return }
        
        // Перевіряємо, чи позиція не дуже близько до кінця (не менше 5 секунд від кінця)
        // Якщо так, не відновлюємо, щоб не пропустити кінець
        if let duration = player.currentItem?.duration.seconds, position.position >= duration - 5 {
            return
        }
        
        let time = CMTime(seconds: position.position, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero) { completed in
            if completed {
                // Можна додати візуальний індикатор відновлення
            }
        }
    }
    
    private func setupTimeObserver(for player: AVPlayer) {
        // Зберігаємо позицію кожну хвилину (60 секунд)
        let interval = CMTime(seconds: 60, preferredTimescale: CMTimeScale(NSEC_PER_SEC))
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: interval, queue: .main) { [weak player] time in
            guard let player = player else { return }
            saveCurrentPosition(for: player)
        }
    }
    
    private func removeTimeObserver(player: AVPlayer) {
        if let observer = timeObserver {
            player.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func saveCurrentPosition(for player: AVPlayer) {
        guard let currentItem = player.currentItem else { return }
        let currentTime = player.currentTime().seconds
        
        // Не зберігаємо, якщо відео ще не готове або позиція дуже мала
        guard currentItem.status == .readyToPlay, currentTime > 1 else { return }
        
        let voiceActingId = configuration.acting.voiceId
        let translatorId = configuration.acting.translatorId
        let seasonId = configuration.season?.seasonId
        let episodeId = configuration.episode?.episodeId
        
        // Шукаємо існуючу позицію
        if let position = playerPositions.first(where: { position in
            position.id == voiceActingId &&
            position.acting == translatorId &&
            position.season == seasonId &&
            position.episode == episodeId
        }) {
            position.position = currentTime
        } else {
            // Створюємо нову позицію
            let position = PlayerPosition(
                id: voiceActingId,
                acting: translatorId,
                season: seasonId,
                episode: episodeId,
                position: currentTime
            )
            modelContext.insert(position)
        }
        
        // Зберігаємо контекст
        try? modelContext.save()
    }
    
    private func findPlayerPosition() -> PlayerPosition? {
        let voiceActingId = configuration.acting.voiceId
        let translatorId = configuration.acting.translatorId
        let seasonId = configuration.season?.seasonId
        let episodeId = configuration.episode?.episodeId
        
        return playerPositions.first(where: { position in
            position.id == voiceActingId &&
            position.acting == translatorId &&
            position.season == seasonId &&
            position.episode == episodeId
        })
    }
}

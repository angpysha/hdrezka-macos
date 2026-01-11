import AVKit
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
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()

            if let player {
                TVPlayerViewController(player: player) {
                    dismiss()
                }
                .ignoresSafeArea()
                .onAppear {
                    player.play()
                }
                .onDisappear {
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

        await MainActor.run {
            self.player = player
        }
    }
}

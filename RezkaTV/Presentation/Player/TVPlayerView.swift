import AVKit
import SwiftUI
import Combine

struct TVPlayerView: View {
    let data: PlayerData
    
    @State private var player: AVPlayer?
    @State private var isLoading = true
    @State private var error: String?
    
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            if let player = player {
                VideoPlayer(player: player) {
                    // Можна додати власні контроли тут, якщо потрібно
                }
                .ignoresSafeArea()
                .onAppear {
                    player.play()
                }
                .onDisappear {
                    player.pause()
                }
            } else if isLoading {
                VStack(spacing: 40) {
                    ProgressView()
                        .scaleEffect(2.0)
                    
                    Text("key.loading")
                        .font(.system(size: 32))
                        .foregroundStyle(.secondary)
                }
            } else if let error = error {
                VStack(spacing: 40) {
                    Image(systemName: "exclamationmark.triangle")
                        .font(.system(size: 80))
                        .foregroundStyle(.secondary)
                    
                    Text(error)
                        .font(.system(size: 28))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 90)
                    
                    Button {
                        dismiss()
                    } label: {
                        Text("key.close")
                            .font(.system(size: 28))
                    }
                }
            }
        }
        .background(.black)
        .task {
            await loadVideo()
        }
    }
    
    private func loadVideo() async {
        isLoading = true
        error = nil
        
        // Тут потрібна логіка отримання відео потоку з вашого API
        // Припустимо, що PlayerData містить URL або інформацію для отримання потоку
        
        do {
            // Приклад: якщо в data є videoURL
            // let url = data.videoURL
            // let player = AVPlayer(url: url)
            
            // Поки що створюємо placeholder
            // В реальному проекті тут буде виклик UseCase для отримання потоку
            
            // Заглушка для демонстрації
            guard let videoURL = data.videoURL else {
                throw NSError(domain: "TVPlayer", code: -1, userInfo: [
                    NSLocalizedDescriptionKey: "Video URL not available"
                ])
            }
            
            let player = AVPlayer(url: videoURL)
            
            // Налаштування плеєра
            player.allowsExternalPlayback = true
            player.usesExternalPlaybackWhileExternalScreenIsActive = true
            
            // Відновлення позиції відтворення, якщо є
            if let savedPosition = data.position {
                let time = CMTime(seconds: savedPosition, preferredTimescale: 1)
                await player.seek(to: time)
            }
            
            await MainActor.run {
                self.player = player
                self.isLoading = false
            }
            
        } catch {
            await MainActor.run {
                self.error = error.localizedDescription
                self.isLoading = false
            }
        }
    }
}

// Розширення PlayerData для tvOS
extension PlayerData {
    var videoURL: URL? {
        // Тут потрібно отримати URL відео з даних
        // Це залежить від вашої структури PlayerData
        // Поки що повертаємо nil
        return nil
    }
    
    var position: Double? {
        // Отримання збереженої позиції відтворення
        return nil
    }
}


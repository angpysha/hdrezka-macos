import Foundation
import SwiftData

// Заглушка для Downloader на tvOS
// tvOS не підтримує завантаження файлів так, як macOS
// Цей клас забезпечує сумісність коду

@Observable
class TVDownloaderStub {
    static let shared = TVDownloaderStub()
    
    var downloads: [Download] = []
    
    private init() {}
    
    func download(_ data: DownloadData) {
        // На tvOS не підтримується завантаження
        print("Downloads are not supported on tvOS")
    }
    
    func remove(_ gid: String) {
        // Не підтримується
    }
    
    func pause(_ gid: String) {
        // Не підтримується
    }
    
    func resume(_ gid: String) {
        // Не підтримується
    }
    
    func setModelContext(modelContext: ModelContext) {
        // Не потрібно на tvOS
    }
    
    func terminate() {
        // Нічого не робимо
    }
}

// Alias для сумісності з існуючим кодом
typealias Downloader = TVDownloaderStub


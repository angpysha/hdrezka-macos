import Defaults
import SwiftUI

// Корисні розширення для tvOS

extension View {
    /// Додає ефект масштабування при фокусі
    func tvFocusScale(isFocused: Bool, scale: CGFloat = 1.1) -> some View {
        scaleEffect(isFocused ? scale : 1.0)
            .animation(.easeInOut(duration: 0.2), value: isFocused)
    }

    /// Додає тінь для фокусу
    func tvFocusShadow(isFocused: Bool) -> some View {
        shadow(radius: isFocused ? 20 : 8)
    }

    /// Безпечні відступи для tvOS
    func tvSafeArea() -> some View {
        padding(.horizontal, 90)
    }
}

// Theme підтримка для tvOS
enum Theme: Int, CaseIterable, Identifiable, Defaults.Serializable {
    case system
    case light
    case dark

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .system: String(localized: "key.theme.system")
        case .light: String(localized: "key.theme.light")
        case .dark: String(localized: "key.theme.dark")
        }
    }

    var scheme: ColorScheme? {
        switch self {
        case .system: nil
        case .light: .light
        case .dark: .dark
        }
    }
}

// DefaultQuality для tvOS
enum DefaultQuality: String, CaseIterable, Identifiable, Defaults.Serializable {
    case ask
    case q360 = "360p"
    case q480 = "480p"
    case q720 = "720p"
    case q1080 = "1080p"
    case q1440 = "1440p"
    case q2160 = "2160p"

    var id: String { rawValue }

    var name: String { rawValue }
}

// SpatialAudio для tvOS
enum SpatialAudio: Int, CaseIterable, Identifiable, Defaults.Serializable {
    case off
    case on
    case auto

    var id: Int { rawValue }

    var name: String {
        switch self {
        case .off: String(localized: "key.off")
        case .on: String(localized: "key.on")
        case .auto: String(localized: "key.auto")
        }
    }
}

// URL extension для безпечного отримання host
extension URL {
    func host() -> String? {
        host
    }
}

// Genres для tvOS
enum Genres: LocalizedStringKey, CaseIterable, Identifiable {
    case all = "key.genres.all"
    case films = "key.genres.films"
    case series = "key.genres.series"
    case cartoons = "key.genres.cartoons"
    case anime = "key.genres.anime"
    case show = "key.genres.show"

    var id: Genres { self }

    var genreCode: Int {
        switch self {
        case .all: 0
        case .films: 1
        case .series: 2
        case .cartoons: 3
        case .anime: 82
        case .show: 4
        }
    }
}

// BookmarkFilters для tvOS
enum BookmarkFilters: LocalizedStringKey, CaseIterable, Identifiable {
    case added = "key.filters.date"
    case year = "key.filters.year"
    case popular = "key.filters.popular"

    var id: BookmarkFilters { self }
}

// Filters для tvOS (з ListView)
enum Filters: LocalizedStringKey, CaseIterable, Identifiable {
    case latest = "key.filters.latest"
    case popular = "key.filters.popular"
    case soon = "key.filters.soon"
    case watching = "key.filters.watching_now"

    var id: Filters { self }
}

// NewFilters для tvOS (з ListView)
enum NewFilters: LocalizedStringKey, CaseIterable, Identifiable {
    case latest = "key.filters.latest"
    case popular = "key.filters.popular"
    case watching = "key.filters.watching_now"

    var id: NewFilters { self }
}

// Placeholder типи для сумісності
struct Download: Identifiable, Equatable {
    let id: String
    let title: String
    let progress: Double

    static func == (lhs: Download, rhs: Download) -> Bool {
        lhs.id == rhs.id
    }
}

struct DownloadData: Codable {
    let url: URL
    let title: String
}

// Локалізація helper
extension String {
    var localized: String {
        NSLocalizedString(self, comment: "")
    }
}

import SwiftUI

// tvOS адаптація AppState
// На відміну від macOS версії, тут немає window reference та деяких інших macOS-специфічних властивостей

@Observable
class AppState {
    static let shared = AppState()
    
    var selectedTab: Tabs = .home
    
    var isSignInPresented = false
    var isSignUpPresented = false
    var isRestorePresented = false
    var isSignOutPresented = false
    var isPremiumPresented = false
    var commentsRulesPresented = false
    
    private init() {}
}

// Enum для табів
enum Tabs: String, CaseIterable, Identifiable {
    case home
    case search
    case categories
    case collections
    case bookmarks
    case watchingLater
    case settings
    
    var id: String { rawValue }
    
    var label: String {
        switch self {
        case .home: return String(localized: "key.home")
        case .search: return String(localized: "key.search")
        case .categories: return String(localized: "key.categories")
        case .collections: return String(localized: "key.collections")
        case .bookmarks: return String(localized: "key.bookmarks")
        case .watchingLater: return String(localized: "key.watching_later")
        case .settings: return String(localized: "key.settings")
        }
    }
    
    var image: String {
        switch self {
        case .home: return "house.fill"
        case .search: return "magnifyingglass"
        case .categories: return "square.grid.2x2.fill"
        case .collections: return "rectangle.stack.fill"
        case .bookmarks: return "bookmark.fill"
        case .watchingLater: return "clock.fill"
        case .settings: return "gear"
        }
    }
    
    var needAccount: Bool {
        switch self {
        case .bookmarks, .watchingLater:
            return true
        default:
            return false
        }
    }
    
    var role: TabRole? {
        return nil
    }
}

// Destinations для навігації
enum Destinations: Hashable {
    case category(HomeCategory)
    case person(PersonSimple)
    case collection(MoviesCollection)
}

// HomeCategory enum для навігації (з HomeViewModel)
enum HomeCategory: String, CaseIterable, Hashable {
    case hot = "key.filters.hot"
    case watchingNow = "key.filters.watching_now"
    case newest = "key.filters.newest"
    case latest = "key.filters.latest"
    case popular = "key.filters.popular"
    case soon = "key.filters.soon"
    
    var localized: String {
        NSLocalizedString(rawValue, comment: "")
    }
}


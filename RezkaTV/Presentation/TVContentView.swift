import Alamofire
import Combine
import Defaults
import FactoryKit
import SwiftUI

struct TVContentView: View {
    @Injected(\.logoutUseCase) private var logoutUseCase
    @Injected(\.getVersionUseCase) private var getVersionUseCase

    @Default(.isLoggedIn) private var isLoggedIn
    @Default(.mirror) private var mirror
    @Default(.isUserPremium) private var isUserPremium
    @Default(.lastHdrezkaAppVersion) private var lastHdrezkaAppVersion

    @Environment(AppState.self) private var appState

    @State private var subscriptions: Set<AnyCancellable> = []

    var body: some View {
        @Bindable var appState = appState

        TabView(selection: $appState.selectedTab) {
            // Основні таби, які не потребують акаунт
            ForEach(Tabs.allCases.filter { !$0.needAccount }) { tab in
                NavigationStack {
                    tab.tvContent()
                        .navigationTitle(tab.label)
                }
                .tabItem {
                    Label {
                        Text(tab.label)
                    } icon: {
                        Image(systemName: tab.image)
                    }
                }
                .tag(tab)
            }

            // Таби для залогінених користувачів
            if isLoggedIn {
                ForEach(Tabs.allCases.filter(\.needAccount)) { tab in
                    NavigationStack {
                        tab.tvContent()
                            .navigationTitle(tab.label)
                    }
                    .tabItem {
                        Label {
                            Text(tab.label)
                        } icon: {
                            Image(systemName: tab.image)
                        }
                    }
                    .tag(tab)
                }
            }

            // Таб налаштувань
            NavigationStack {
                TVSettingsView()
                    .navigationTitle("key.settings")
            }
            .tabItem {
                Label {
                    Text("key.settings")
                } icon: {
                    Image(systemName: "gear")
                }
            }
            .tag(Tabs.settings)
        }
        .tabViewStyle(.automatic)
        .task {
            getVersionUseCase()
                .receive(on: DispatchQueue.main)
                .sink { _ in } receiveValue: { version in
                    lastHdrezkaAppVersion = version
                }
                .store(in: &subscriptions)
        }
        .onChange(of: isLoggedIn) {
            if !isLoggedIn, appState.selectedTab.needAccount {
                appState.selectedTab = .home
            }
        }
        .sheet(isPresented: $appState.isSignInPresented) {
            TVSignInSheetView()
        }
        .sheet(isPresented: $appState.isSignUpPresented) {
            TVSignUpSheetView()
        }
        .sheet(isPresented: $appState.isRestorePresented) {
            TVRestoreSheetView()
        }
        .alert("key.sign_out.label", isPresented: $appState.isSignOutPresented) {
            Button(role: .destructive) {
                logoutUseCase()
            } label: {
                Text("key.yes")
            }
            Button(role: .cancel) {
                Text("key.cancel")
            }
        } message: {
            Text("key.sign_out.q")
        }
        .alert("key.premium_content", isPresented: $appState.isPremiumPresented) {
            Button("key.ok") {
                // На tvOS не можемо відкрити браузер так просто
                // Можливо показати QR код або інструкції
            }
        } message: {
            Text("key.premium.description")
        }
    }
}

// Розширення для Tabs щоб повертати tvOS-адаптовані views
extension Tabs {
    @ViewBuilder
    func tvContent() -> some View {
        switch self {
        case .home:
            TVHomeView()
        case .search:
            TVSearchView()
        case .categories:
            TVCategoriesView()
        case .collections:
            TVCollectionsView()
        case .bookmarks:
            TVBookmarksView()
        case .watchingLater:
            TVWatchingLaterView()
        default:
            Text("Coming soon")
        }
    }
}

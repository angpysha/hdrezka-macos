import Defaults
import SwiftUI

struct TVSettingsView: View {
    @Default(.isLoggedIn) private var isLoggedIn
    @Default(.mirror) private var mirror
    @Default(.theme) private var theme
    @Default(.isUserPremium) private var isUserPremium
    @Environment(AppState.self) private var appState

    var body: some View {
        List {
            Section("key.account") {
                if isLoggedIn {
                    if let premium = isUserPremium {
                        HStack {
                            Text("key.premium")
                                .font(.system(size: 28))
                            Spacer()
                            Text("\(premium) " + String(localized: "key.days"))
                                .font(.system(size: 24))
                                .foregroundStyle(.secondary)
                        }
                    }

                    Button {
                        appState.isSignOutPresented = true
                    } label: {
                        HStack {
                            Text("key.sign_out")
                                .font(.system(size: 28))
                            Spacer()
                            Image(systemName: "arrow.left")
                        }
                    }
                } else {
                    Button {
                        appState.isSignInPresented = true
                    } label: {
                        HStack {
                            Text("key.sign_in")
                                .font(.system(size: 28))
                            Spacer()
                            Image(systemName: "arrow.right")
                        }
                    }

                    Button {
                        appState.isSignUpPresented = true
                    } label: {
                        HStack {
                            Text("key.sign_up")
                                .font(.system(size: 28))
                            Spacer()
                            Image(systemName: "person.badge.plus")
                        }
                    }
                }
            }

            Section("key.appearance") {
                Picker("key.theme", selection: $theme) {
                    ForEach(Theme.allCases) { themeOption in
                        Text(themeOption.name)
                            .tag(themeOption)
                    }
                }
                .font(.system(size: 28))
            }

            Section("key.network") {
                HStack {
                    Text("key.mirror")
                        .font(.system(size: 28))
                    Spacer()
                    Text(mirror.host() ?? "")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
            }

            Section("key.about") {
                HStack {
                    Text("key.version")
                        .font(.system(size: 28))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }

                HStack {
                    Text("key.build")
                        .font(.system(size: 28))
                    Spacer()
                    Text(Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "")
                        .font(.system(size: 24))
                        .foregroundStyle(.secondary)
                }
            }
        }
        .listStyle(.grouped)
    }
}

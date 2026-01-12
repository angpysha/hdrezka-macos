import Combine
import Defaults
import FactoryKit
import SwiftUI

struct TVSignInSheetView: View {
    @Injected(\.signInUseCase) private var signInUseCase

    @Default(.isLoggedIn) private var isLoggedIn

    @Environment(\.dismiss) private var dismiss
    @Environment(AppState.self) private var appState

    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var subscriptions: Set<AnyCancellable> = []

    @FocusState private var focusedField: Field?

    enum Field {
        case username
        case password
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text("key.sign_in")
                    .font(.system(size: 56, weight: .bold))
                    .padding(.top, 60)

                VStack(spacing: 30) {
                    // Username
                    VStack(alignment: .leading, spacing: 15) {
                        Text("key.username")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)

                        TextField("", text: $username)
                            .textFieldStyle(.plain)
                            .font(.system(size: 32))
                            .padding(25)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                            .focused($focusedField, equals: .username)
                            .onSubmit {
                                focusedField = .password
                            }
                    }

                    // Password
                    VStack(alignment: .leading, spacing: 15) {
                        Text("key.password")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)

                        SecureField("", text: $password)
                            .textFieldStyle(.plain)
                            .font(.system(size: 32))
                            .padding(25)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(15)
                            .focused($focusedField, equals: .password)
                            .onSubmit {
                                // На tvOS прибираємо фокус, щоб фокус перейшов на кнопку
                                focusedField = nil
                            }
                    }
                }
                .frame(maxWidth: 800)
                .padding(.horizontal, 60)

                if let error {
                    Text(error)
                        .font(.system(size: 24))
                        .foregroundStyle(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 60)
                }

                // Buttons
                VStack(spacing: 25) {
                    Button {
                        signIn()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("key.sign_in")
                            }
                        }
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 800)
                        .padding(.vertical, 25)
                        .background(username.isEmpty || password.isEmpty || isLoading ? Color.gray : Color.accentColor)
                        .cornerRadius(15)
                    }
                    .disabled(username.isEmpty || password.isEmpty || isLoading)
                    .buttonStyle(.plain)

                    HStack(spacing: 40) {
                        Button {
                            dismiss()
                            appState.isSignUpPresented = true
                        } label: {
                            Text("key.sign_up")
                                .font(.system(size: 28))
                        }

                        Button {
                            dismiss()
                            appState.isRestorePresented = true
                        } label: {
                            Text("key.restore")
                                .font(.system(size: 28))
                        }
                    }
                }
                .padding(.horizontal, 60)

                Spacer()
            }
            .padding(.bottom, 60)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 28))
                    }
                }
            }
        }
        .onAppear {
            focusedField = .username
        }
        .onChange(of: isLoggedIn) {
            if isLoggedIn {
                dismiss()
            }
        }
    }

    private func signIn() {
        isLoading = true
        error = nil

        signInUseCase(login: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                if case let .failure(error) = completion {
                    self.error = error.localizedDescription
                }
            } receiveValue: { success in
                isLoading = false
                if success {
                    isLoggedIn = true
                    dismiss()
                } else {
                    error = String(localized: "key.sign_in.error")
                }
            }
            .store(in: &subscriptions)
    }
}

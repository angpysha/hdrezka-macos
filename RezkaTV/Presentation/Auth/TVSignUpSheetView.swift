import Combine
import Defaults
import FactoryKit
import SwiftUI

struct TVSignUpSheetView: View {
    @Injected(\.signUpUseCase) private var signUpUseCase
    
    @Default(.isLoggedIn) private var isLoggedIn
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var subscriptions: Set<AnyCancellable> = []
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case username, email, password, confirmPassword
    }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 50) {
                    Text("key.sign_up")
                        .font(.system(size: 56, weight: .bold))
                        .padding(.top, 60)
                    
                    VStack(spacing: 30) {
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
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("key.email")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                            
                            TextField("", text: $email)
                                .textFieldStyle(.plain)
                                .font(.system(size: 32))
                                .padding(25)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .keyboardType(.emailAddress)
                                .textContentType(.emailAddress)
                                .focused($focusedField, equals: .email)
                        }
                        
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
                        }
                        
                        VStack(alignment: .leading, spacing: 15) {
                            Text("key.confirm_password")
                                .font(.system(size: 28))
                                .foregroundStyle(.secondary)
                            
                            SecureField("", text: $confirmPassword)
                                .textFieldStyle(.plain)
                                .font(.system(size: 32))
                                .padding(25)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .focused($focusedField, equals: .confirmPassword)
                                .onSubmit {
                                    signUp()
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
                    
                    Button {
                        signUp()
                    } label: {
                        HStack {
                            if isLoading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("key.sign_up")
                            }
                        }
                        .font(.system(size: 32, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(maxWidth: 800)
                        .padding(.vertical, 25)
                        .background(isFormValid ? Color.accentColor : Color.gray)
                        .cornerRadius(15)
                    }
                    .disabled(!isFormValid || isLoading)
                    .buttonStyle(.plain)
                    .padding(.horizontal, 60)
                    
                    Spacer(minLength: 60)
                }
            }
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
        .onChange(of: isLoggedIn) {
            if isLoggedIn {
                dismiss()
            }
        }
    }
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty &&
        password == confirmPassword && password.count >= 6
    }
    
    private func signUp() {
        guard isFormValid else { return }
        
        isLoading = true
        error = nil
        
        signUpUseCase(email: email, login: username, password: password)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                if case let .failure(error) = completion {
                    self.error = error.localizedDescription
                }
            } receiveValue: { _ in }
            .store(in: &subscriptions)
    }
}


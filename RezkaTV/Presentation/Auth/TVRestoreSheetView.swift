import Combine
import FactoryKit
import SwiftUI

struct TVRestoreSheetView: View {
    @Injected(\.restoreUseCase) private var restoreUseCase
    
    @Environment(\.dismiss) private var dismiss
    
    @State private var email = ""
    @State private var isLoading = false
    @State private var error: String?
    @State private var success = false
    @State private var subscriptions: Set<AnyCancellable> = []
    
    @FocusState private var isEmailFocused: Bool
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 50) {
                Text("key.restore")
                    .font(.system(size: 56, weight: .bold))
                    .padding(.top, 60)
                
                if success {
                    VStack(spacing: 30) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 100))
                            .foregroundStyle(.green)
                        
                        Text("key.restore.success")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.horizontal, 60)
                } else {
                    VStack(spacing: 40) {
                        Text("key.restore.description")
                            .font(.system(size: 28))
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 60)
                        
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
                                .focused($isEmailFocused)
                                .onSubmit {
                                    restore()
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
                            restore()
                        } label: {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .tint(.white)
                                } else {
                                    Text("key.restore.send")
                                }
                            }
                            .font(.system(size: 32, weight: .semibold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: 800)
                            .padding(.vertical, 25)
                            .background(email.isEmpty || isLoading ? Color.gray : Color.accentColor)
                            .cornerRadius(15)
                        }
                        .disabled(email.isEmpty || isLoading)
                        .buttonStyle(.plain)
                        .padding(.horizontal, 60)
                    }
                }
                
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
            isEmailFocused = true
        }
    }
    
    private func restore() {
        isLoading = true
        error = nil
        
        restoreUseCase(login: email)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                isLoading = false
                if case let .failure(error) = completion {
                    self.error = error.localizedDescription
                }
            } receiveValue: { _ in
                success = true
                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                    dismiss()
                }
            }
            .store(in: &subscriptions)
    }
}


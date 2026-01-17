import Combine
import FactoryKit
import SwiftUI

struct TVCreateBookmarkSheetView: View {
    @Injected(\.createBookmarksCategoryUseCase) private var createBookmarksCategoryUseCase

    @State private var subscriptions: Set<AnyCancellable> = []

    @Environment(\.dismiss) private var dismiss

    @State private var name: String = ""
    @State private var state: EmptyState = .data

    private enum FocusedField {
        case name
    }

    @FocusState private var focusedField: FocusedField?

    var body: some View {
        Group {
            switch state {
            case .data:
                VStack(alignment: .center, spacing: 40) {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "bookmark.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.accentColor)

                        Text("key.create.label")
                            .font(.system(size: 48, weight: .semibold))

                        Text("key.create.description")
                            .font(.system(size: 32))
                            .lineLimit(2, reservesSpace: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }

                    VStack(alignment: .center, spacing: 20) {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("key.name")
                                .font(.system(size: 32, weight: .semibold))

                            TextField("key.name", text: $name, prompt: Text(String(localized: "key.name").lowercased()))
                                .textFieldStyle(.plain)
                                .font(.system(size: 32))
                                .padding(.horizontal, 30)
                                .padding(.vertical, 20)
                                .background(Color.gray.opacity(0.2))
                                .cornerRadius(15)
                                .focused($focusedField, equals: .name)
                                .onSubmit {
                                    if !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                        load()
                                    }
                                }
                        }
                        .frame(maxWidth: 600)
                    }

                    VStack(alignment: .center, spacing: 20) {
                        Button {
                            load()
                        } label: {
                            Text("key.create")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 400, height: 60)
                                .background(!name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? Color.accentColor : Color.gray.opacity(0.5), in: .rect(cornerRadius: 15))
                        }
                        .buttonStyle(.plain)
                        .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                        .animation(.easeInOut, value: !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                        Button {
                            dismiss()
                        } label: {
                            Text("key.cancel")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 400, height: 60)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .onAppear {
                    focusedField = .name
                }
            case .loading:
                VStack(alignment: .center, spacing: 40) {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "bookmark.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.accentColor)

                        Text("key.create.enter")
                            .font(.system(size: 48, weight: .semibold))

                        Text("key.request.wait")
                            .font(.system(size: 32))
                            .lineLimit(1, reservesSpace: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    ProgressView()
                        .scaleEffect(2.0)

                    VStack(alignment: .center, spacing: 20) {
                        Button {
                            subscriptions.flush()

                            withAnimation(.easeInOut) {
                                state = .data
                            }
                        } label: {
                            Text("key.cancel")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 400, height: 60)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                }
            case .error:
                VStack(alignment: .center, spacing: 40) {
                    VStack(alignment: .center, spacing: 10) {
                        Image(systemName: "bookmark.circle")
                            .font(.system(size: 80))
                            .foregroundStyle(Color.accentColor)

                        Text("key.ops")
                            .font(.system(size: 48, weight: .semibold))

                        Text("key.name.error")
                            .font(.system(size: 32))
                            .lineLimit(1, reservesSpace: true)
                            .multilineTextAlignment(.center)
                            .foregroundStyle(.secondary)
                    }

                    Spacer()

                    VStack(alignment: .center, spacing: 20) {
                        Button {
                            withAnimation(.easeInOut) {
                                state = .data
                            }
                        } label: {
                            Text("key.retry")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 400, height: 60)
                                .background(Color.accentColor)
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)

                        Button {
                            dismiss()
                        } label: {
                            Text("key.cancel")
                                .font(.system(size: 32, weight: .semibold))
                                .foregroundStyle(.white)
                                .frame(width: 400, height: 60)
                                .background(Color.gray.opacity(0.5))
                                .cornerRadius(15)
                        }
                        .buttonStyle(.plain)
                    }
                }
            }
        }
        .padding(.horizontal, 60)
        .padding(.top, 60)
        .padding(.bottom, 40)
        .frame(width: 1000)
    }

    private func load() {
        withAnimation(.easeInOut) {
            state = .loading
        }

        createBookmarksCategoryUseCase(name: name.trimmingCharacters(in: .whitespacesAndNewlines))
            .receive(on: DispatchQueue.main)
            .sink { completion in
                guard case .failure = completion else { return }

                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    withAnimation(.easeInOut) {
                        state = .error
                    }
                }
            } receiveValue: { _ in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
            .store(in: &subscriptions)
    }
}

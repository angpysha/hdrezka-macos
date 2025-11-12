import SwiftUI

struct TVEmptyStateView: View {
    let message: String
    let systemImage: String
    let action: (() -> Void)?

    init(
        _ message: String,
        systemImage: String = "film",
        action: (() -> Void)? = nil,
    ) {
        self.message = message
        self.systemImage = systemImage
        self.action = action
    }

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: systemImage)
                .font(.system(size: 100))
                .foregroundStyle(.secondary)

            Text(message)
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            if let action {
                Button {
                    action()
                } label: {
                    Text("key.retry")
                        .font(.system(size: 28))
                        .padding(.horizontal, 50)
                        .padding(.vertical, 20)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(90)
    }
}

struct TVLoadingStateView: View {
    var body: some View {
        VStack(spacing: 40) {
            ProgressView()
                .scaleEffect(2.5)

            Text("key.loading")
                .font(.system(size: 32))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TVErrorStateView: View {
    let error: Error
    let retry: () -> Void

    var body: some View {
        VStack(spacing: 40) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 100))
                .foregroundStyle(.red)

            Text(error.localizedDescription)
                .font(.system(size: 28))
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)

            Button {
                retry()
            } label: {
                Text("key.retry")
                    .font(.system(size: 28))
                    .padding(.horizontal, 50)
                    .padding(.vertical, 20)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding(90)
    }
}

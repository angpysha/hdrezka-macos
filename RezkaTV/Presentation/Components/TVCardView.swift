import Kingfisher
import SwiftUI

struct TVCardView: View {
    let movie: MovieSimple
    let width: CGFloat
    @FocusState private var isFocused: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Постер
            if let posterURL = movie.poster, let url = URL(string: posterURL) {
                KFImage(url)
                    .placeholder {
                        Rectangle()
                            .fill(Color.gray.opacity(0.3))
                    }
                    .resizable()
                    .aspectRatio(2 / 3, contentMode: .fit)
                    .frame(width: width)
                    .cornerRadius(16)
                    .shadow(radius: isFocused ? 20 : 5)
                    .scaleEffect(isFocused ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: isFocused)
            } else {
                Rectangle()
                    .fill(Color.gray.opacity(0.3))
                    .aspectRatio(2 / 3, contentMode: .fit)
                    .frame(width: width)
                    .cornerRadius(16)
            }

            // Назва фільму
            if let name = movie.name {
                Text(name)
                    .font(.system(size: 24, weight: .medium))
                    .lineLimit(2)
                    .frame(width: width, alignment: .leading)
            }

            // Додаткова інформація
            if let details = movie.details {
                Text(details)
                    .font(.system(size: 20))
                    .foregroundStyle(.secondary)
                    .lineLimit(1)
                    .frame(width: width, alignment: .leading)
            }
        }
        .focusable(true)
        .focused($isFocused)
    }
}

import SwiftUI
import UIKit

// UIViewController для обробки натискань Menu (ESC) на tvOS
private class BackHandlingController: UIViewController {
    var onMenuPressed: (() -> Void)?

    override func pressesBegan(_ presses: Set<UIPress>, with event: UIPressesEvent?) {
        // Перевіряємо, чи натиснуто кнопку Menu (ESC)
        if presses.contains(where: { $0.type == .menu }) {
            onMenuPressed?()
            // Не викликаємо super, щоб запобігти закриттю застосунку
            return
        }
        super.pressesBegan(presses, with: event)
    }
}

// SwiftUI wrapper для обробки натискань Menu (ESC)
struct TVBackHandler<Content: View>: UIViewControllerRepresentable {
    let content: Content
    let onMenu: () -> Void

    func makeUIViewController(context: Context) -> UIViewController {
        let controller = BackHandlingController()
        controller.onMenuPressed = onMenu
        
        let hosting = UIHostingController(rootView: content)
        // Додаємо hosting controller як child, щоб зберегти навігацію
        controller.addChild(hosting)
        controller.view.addSubview(hosting.view)
        hosting.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hosting.view.topAnchor.constraint(equalTo: controller.view.topAnchor),
            hosting.view.leadingAnchor.constraint(equalTo: controller.view.leadingAnchor),
            hosting.view.trailingAnchor.constraint(equalTo: controller.view.trailingAnchor),
            hosting.view.bottomAnchor.constraint(equalTo: controller.view.bottomAnchor)
        ])
        hosting.didMove(toParent: controller)
        
        return controller
    }

    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        // Оновлюємо контент, якщо потрібно
        if let controller = uiViewController as? BackHandlingController,
           let hosting = controller.children.first as? UIHostingController<Content> {
            hosting.rootView = content
        }
    }
}

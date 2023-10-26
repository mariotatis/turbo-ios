import Foundation
import Strada
import UIKit


final class NavButtonComponent: BridgeComponent {
    
    override class var name: String { "nav-button" }
    
    private var addedButtonTitles = Set<String>()
    private var leftBarButtonItems: [UIBarButtonItem] = []
    private var rightBarButtonItems: [UIBarButtonItem] = []
    
    override func onViewWillAppear() {
        resetBarButtonItems()
    }
    
    override func onReceive(message: Message) {
        guard let event = Event(rawValue: message.event) else {
            return
        }
        if event == .connect {
            handleConnectEvent(message: message)
            guard let data: MessageData = message.data() else { return }
            configureBarButton(with: data.title, position: data.position, systemName: data.systemName, message: message)
        }
    }

    private func performAction(message: Message) {
        reply(with: message)
    }

    // MARK: Private

    private weak var navBarButtonItem: UIBarButtonItem?

    private var viewController: UIViewController? {
        return delegate.destination as? UIViewController
    }

    private func handleConnectEvent(message: Message) {
        guard let data: MessageData = message.data() else { return }
        
        if !addedButtonTitles.contains(data.title) {
            addedButtonTitles.insert(data.title)
        }
    }
    
    private func configureBarButton(with title: String, position: String?, systemName: String?, message: Message) {
        guard let viewController = viewController else { return }

        var action: UIAction
        var item: UIBarButtonItem
        
        action = UIAction { [weak self] _ in
            self?.performAction(message: message)
        }

        if let systemName = systemName {
            let symbolImage = UIImage(systemName: systemName)
            let customSymbolImage = symbolImage?.withConfiguration(UIImage.SymbolConfiguration(pointSize: 23))
            let customView = UIImageView(image: customSymbolImage)
            let button = UIButton(type: .custom)
            button.addSubview(customView)
            button.addAction(action, for: .touchUpInside)
            item = UIBarButtonItem(customView: button)
        } else {
            item = UIBarButtonItem(title: title, primaryAction: action)
        }
        if let position = position {
            if position == "left" {
                GlobalNavButtonItems.leftBarButtonItems.append(item)
                viewController.navigationItem.leftBarButtonItems = GlobalNavButtonItems.leftBarButtonItems
            } else if position == "right" {
                GlobalNavButtonItems.rightBarButtonItems.append(item)
                viewController.navigationItem.rightBarButtonItems = GlobalNavButtonItems.rightBarButtonItems
            }
        } else {
            GlobalNavButtonItems.rightBarButtonItems.append(item)
            viewController.navigationItem.rightBarButtonItems = GlobalNavButtonItems.rightBarButtonItems
        }
    }
}

// MARK: Events

private extension NavButtonComponent {
    enum Event: String { case connect }
}

// MARK: Message data

private extension NavButtonComponent {
    struct MessageData: Decodable {
        let title: String
        let position: String?
        let systemName: String?
    }
}

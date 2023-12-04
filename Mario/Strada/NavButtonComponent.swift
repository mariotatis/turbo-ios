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
            configureBarButton(with: data.title, position: data.position, systemName: data.systemName, color: data.color, message: message)
        }
    }

    private func performAction(message: Message) {
        guard let data: MessageData = message.data() else { return }
        if let action = data.action {
            print("Action: \(action)")
        }
        else{
            reply(with: message)
        }
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
    
    private func configureBarButton(with title: String, position: String?, systemName: String?, color: String?, message: Message) {
        
        guard let viewController = viewController else { return }

        var action: UIAction
        var item: UIBarButtonItem
        
        action = UIAction { [weak self] _ in
            self?.performAction(message: message)
        }

        if let systemName = systemName {
            let symbolImage = UIImage(systemName: systemName)
            
            let fillColor: UIColor = UIColor(hex: color) ?? .systemBlue
            
            let customSymbolImage: UIImage?
            if let symbolImage = symbolImage {
                let tintedSymbolImage = symbolImage.withTintColor(fillColor)
                customSymbolImage = UIGraphicsImageRenderer(size: CGSize(width: 23, height: 20)).image { _ in
                    tintedSymbolImage.draw(in: CGRect(x: 0, y: 0, width: 23, height: 20))
                }
            } else {
                customSymbolImage = nil
            }
            
            let customView = UIImageView(image: customSymbolImage)
            
            let topPadding: CGFloat = 5.0
            
            let button = UIButton(type: .custom)
            button.addSubview(customView)
            button.addAction(action, for: .touchUpInside)
            item = UIBarButtonItem(customView: button)
            
            let verticalPadding = (customView.bounds.height - customView.frame.height) / 2 + topPadding
            customView.frame = CGRect(x: 0, y: verticalPadding, width: customView.bounds.width, height: customView.bounds.height)
        } else {
            item = UIBarButtonItem(title: title, primaryAction: action)
            if let textColor = UIColor(hex: color) {
                item.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: textColor], for: .normal)
            }
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
        let color: String?
        let action: String?
    }
}

// MARK: UIColor Converter

extension UIColor {
    convenience init?(hex: String?) {
        guard let hex = hex else { return nil }

        var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
        hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")

        var rgb: UInt64 = 0

        guard Scanner(string: hexSanitized).scanHexInt64(&rgb) else { return nil }

        let red = CGFloat((rgb & 0xFF0000) >> 16) / 255.0
        let green = CGFloat((rgb & 0x00FF00) >> 8) / 255.0
        let blue = CGFloat(rgb & 0x0000FF) / 255.0

        self.init(red: red, green: green, blue: blue, alpha: 1.0)
    }
}

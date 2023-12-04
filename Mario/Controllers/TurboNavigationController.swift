import Foundation
import UIKit
import Turbo

class TurboNavigationController : UINavigationController {

    var session: Session!
    var modalSession: Session!
    
    private var currentTurboWebViewController: TurboWebViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
         navigationBar.scrollEdgeAppearance = .init()
        //navigationBar.prefersLargeTitles = true
       // configureTabBar()
    }

    func push(url: URL) {
        let properties = session.pathConfiguration?.properties(for: url) ?? [:]
        route(url: url, options: VisitOptions(action: .advance), properties: properties)
    }

    func route(url: URL, options: VisitOptions, properties: PathProperties) {
        
        if let action = properties["action"] as? String {
            print("here ")
            print(action)
            currentTurboWebViewController?.clickElementWithID(action)
        }
        else {
            if presentedViewController != nil {
                dismiss(animated: true)
            }
            let viewController = makeViewController(for: url, properties: properties)
            navigate(to: viewController, action: options.action, properties: properties)

            if isVisitable(properties) {
                visit(viewController: viewController, with: options, modal: isModal(properties))
            }

            if let message = noticeMessage(from: url) {
                presentToast(message.replacingOccurrences(of: "+", with: " "))
            }
        }
    }
}

extension TurboNavigationController {
    private func isModal(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "modal"
    }

    private func isPop(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "pop"
    }

    private func isRefresh(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "refresh"
    }

    private func isNone(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "none"
    }

    private func isClearAll(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "clear-all"
    }

    private func isReplaceAll(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "replace-all"
    }

    private func isReplace(_ properties: PathProperties) -> Bool {
        return properties["presentation"] as? String == "replace"
    }

    private func isVisitable(_ properties: PathProperties) -> Bool {
        return properties["visitable"] as? Bool ?? true
    }

    private func noticeMessage(from url: URL) -> String? {
        URLComponents(url: url, resolvingAgainstBaseURL: false)?.queryItems?.first(where: { $0.name == "notice" })?.value
    }

    private func makeViewController(for url: URL, properties: PathProperties = [:]) -> UIViewController {
        // There are many options for determining how to map urls to view controllers
        // The demo uses the path configuration for determining which view controller and presentation
        // to use, but that's completely optional. You can use whatever logic you prefer to determine
        // how you navigate and route different URLs.

        if let viewController = properties["view-controller"] as? String {
            switch viewController {
            case "numbers":
                return NumbersViewController(title: "Numbers")
            default:
                assertionFailure("Invalid view controller, defaulting to WebView")
            }
        }

        return TurboWebViewController(url: url)
    }

    private func navigate(to viewController: UIViewController, action: VisitAction, properties: PathProperties = [:]) {
        
        if let turboWebViewController = viewController as? TurboWebViewController {
            currentTurboWebViewController = turboWebViewController
        }
        
        if isModal(properties) {
            present(UINavigationController(rootViewController: viewController), animated: true)
        } else if isPop(properties) {
            popViewController(animated: true)
        } else if isRefresh(properties) {
            session.reload()
        } else if isNone(properties) {
            // Will result in no navigation action being taken
        } else if isClearAll(properties) {
            popToRootViewController(animated: true)
        } else if isReplaceAll(properties) {
            setViewControllers([viewController], animated: true)
        } else if isReplace(properties) || action == .replace {
            setViewControllers(Array(viewControllers.dropLast()) + [viewController], animated: false)
        } else {
            pushViewController(viewController, animated: true)
        }
    }

    private func visit(viewController: UIViewController, with options: VisitOptions, modal: Bool = false) {
        guard let visitable = viewController as? Visitable else { return }

        // Each Session corresponds to a single web view. A good rule of thumb
        // is to use a session per navigation stack. Here we're using a different session
        // when presenting a modal. We keep that around for any modal presentations so
        // we don't have to create more than we need since each new session incurs a cold boot visit cost
        if modal {
            modalSession.visit(visitable, options: options)
        } else {
            session.visit(visitable, options: options)
        }
    }
}

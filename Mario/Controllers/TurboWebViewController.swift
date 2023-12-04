import UIKit
import Turbo
import Strada
import WebKit

final class TurboWebViewController: VisitableViewController, ErrorPresenter, BridgeDestination {
    
    private lazy var bridgeDelegate: BridgeDelegate = {
        BridgeDelegate(location: visitableURL.absoluteString, destination: self, componentTypes: BridgeComponent.allTypes)
    }()

    private lazy var dismissModalButton = {
        UIBarButtonItem(image: UIImage(systemName: "xmark"), style: .plain, target: self, action: #selector(dismissModal))
    }()

    // MARK: View lifecycle
    func authenticated(){
        let script =  "document.querySelector(\"meta[name='turbo:authenticated']\").content"

        self.visitableView.webView?.evaluateJavaScript(script) { (result, error) in
            if let error = error {
                //print("Error evaluating JavaScript: \(error)")
            } else if let content = result as? String {
               // print("user_signed_in: \(content)")
            }
        }
    }
    
    func clickElementWithID(_ elementID: String) {
        let javascriptCode = "document.getElementById('\(elementID)').click();"

        // Evaluate the JavaScript code in the WKWebView
        self.visitableView.webView?.evaluateJavaScript(javascriptCode, completionHandler: { (result, error) in
            if let error = error {
                print("Error performing JavaScript click: \(error)")
            }
        })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        navigationItem.backButtonTitle = "Back"

        if presentingViewController != nil {
            navigationItem.leftBarButtonItem = dismissModalButton
        }

        bridgeDelegate.onViewDidLoad()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        bridgeDelegate.onViewWillAppear()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        bridgeDelegate.onViewDidAppear()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        bridgeDelegate.onViewWillDisappear()
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        bridgeDelegate.onViewDidDisappear()
    }

    // MARK: Visitable
    
    override func visitableDidDeactivateWebView() {
        bridgeDelegate.webViewDidBecomeDeactivated()
    }
    
    override func visitableDidActivateWebView(_ webView: WKWebView) {
        bridgeDelegate.webViewDidBecomeActive(webView)
        resetBarButtonItems()
    }
    
    override func showVisitableActivityIndicator(){
        super.showVisitableActivityIndicator()
    }

    override func hideVisitableActivityIndicator(){
        super.hideVisitableActivityIndicator()
    }

    override func visitableDidRender() {
        super.visitableDidRender()
        authenticated()
        resetBarButtonItems()
    }
    // MARK: Actions

    @objc func dismissModal() {
        dismiss(animated: true)
    }
}

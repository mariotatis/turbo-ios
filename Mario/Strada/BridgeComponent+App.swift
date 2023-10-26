import Foundation
import Strada

extension BridgeComponent {
    static var allTypes: [BridgeComponent.Type] {
        [
            FormComponent.self,
            NavButtonComponent.self,
            MenuComponent.self,
            FlashMessageComponent.self
        ]
    }
}

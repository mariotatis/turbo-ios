import UIKit

struct GlobalNavButtonItems {
    static var leftBarButtonItems: [UIBarButtonItem] = []
    static var rightBarButtonItems: [UIBarButtonItem] = []
}

public func resetBarButtonItems() {
    GlobalNavButtonItems.leftBarButtonItems = []
    GlobalNavButtonItems.rightBarButtonItems = []
}

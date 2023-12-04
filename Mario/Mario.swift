import Foundation

struct Mario {
    private static let developmentURL = URL(string: "https://4262-161-10-84-38.ngrok-free.app/")!
    private static let productionURL  = URL(string: "https://4262-161-10-84-38.ngrok-free.app/")!

    static var baseURL:   URL { productionURL }
    static var homeURL:   URL { baseURL.appendingPathComponent("/") }
    static var signInURL: URL { baseURL.appendingPathComponent("/signin") }
}

import Foundation

struct Mario {
    private static let developmentURL = URL(string: "http://localhost:3000")!
    private static let productionURL  = URL(string: "http://localhost:3000")!

    static var baseURL:   URL { productionURL }
    static var homeURL:   URL { baseURL.appendingPathComponent("/") }
    static var signInURL: URL { baseURL.appendingPathComponent("/signin") }
}

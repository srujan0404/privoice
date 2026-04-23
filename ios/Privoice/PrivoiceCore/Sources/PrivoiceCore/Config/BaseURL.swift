import Foundation

public enum Config {
    /// Production backend base URL.
    public static let baseURL = URL(string: "https://privoice.onrender.com")!

    /// Default timeout for HTTP requests (Render cold-start can take 30–60s for the first request).
    public static let requestTimeout: TimeInterval = 60
}

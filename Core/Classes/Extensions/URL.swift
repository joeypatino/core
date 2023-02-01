import Foundation

public extension URL {
    var directory: URL {
        if self.hasDirectoryPath {
            return self
        }
        return self.deletingLastPathComponent()
    }
    
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(queryItems: [URLQueryItem]) -> URL? {
        guard var urlComponents = URLComponents(url: self, resolvingAgainstBaseURL: true) else {
            // URL is not conforming to RFC 3986 (maybe it is only conforming to RFC 1808, RFC 1738, and RFC 2732)
            return nil
        }
        // append the query items to the existing ones
        urlComponents.queryItems = (urlComponents.queryItems ?? []) + queryItems
        
        // return the url from new url components
        return urlComponents.url
    }
    
    /// Returns a new URL by adding the query items, or nil if the URL doesn't support it.
    /// URL must conform to RFC 3986.
    func appending(queryItem: URLQueryItem) -> URL? {
        return self.appending(queryItems: [queryItem])
    }
}

public extension URL {    
    func queryParameter(named: String, resolvingAgainstBaseURL: Bool = true) -> String? {
      guard let url = URLComponents(url: self, resolvingAgainstBaseURL: resolvingAgainstBaseURL) else { return nil }
      return url.queryItems?.first(where: { $0.name == named })?.value
    }
}

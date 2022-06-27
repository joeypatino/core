import Foundation

public extension Encodable {
    subscript(key: String) -> Any? {
        dictionary[key]
    }
    var dictionary: [String: Any] {
        (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
    }
    var array: [[String: Any]] {
        (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [[String: Any]] ?? [[:]]
    }
}

public extension Encodable {
    var encoded: Data? {
        let encodeder = JSONEncoder()
        return try? encodeder.encode(self)
    }
}

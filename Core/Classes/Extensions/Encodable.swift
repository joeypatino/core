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
    
    func dictionary(_ encoder: JSONEncoder = JSONEncoder()) -> [String: Any] {
        (try? JSONSerialization.jsonObject(with: encoder.encode(self))) as? [String: Any] ?? [:]
    }
}

public extension Encodable {
    var encoded: Data? {
        do {
            return try JSONEncoder().pretty().encode(self)
        } catch {
            print("Error", error)
            return nil
        }
    }
}

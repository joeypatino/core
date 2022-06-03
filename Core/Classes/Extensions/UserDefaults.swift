import Foundation

public extension UserDefaults {
    /// Float from UserDefaults.
    /// - Parameter key: key to find float for.
    /// - Returns: Float object for key or nil
    func float(forKey key: String) -> Float? {
        return object(forKey: key) as? Float
    }
    
    /// Date from UserDefaults.
    /// - Parameter key: key to find date for.
    /// - Returns: Date object for key or nil
    func date(forKey key: String) -> Date? {
        return object(forKey: key) as? Date
    }
    
    /// Retrieves a Codable object from UserDefaults.
    /// - Parameters:
    ///   - type: Class that conforms to the Codable protocol.
    ///   - key: Identifier of the object.
    ///   - decoder: Custom JSONDecoder instance. Defaults to `JSONDecoder()`.
    /// - Returns: Codable object for key or nil
    func object<T: Codable>(_ type: T.Type, with key: String, usingDecoder decoder: JSONDecoder = JSONDecoder()) -> T? {
        guard let data = value(forKey: key) as? Data else { return nil }
        return try? decoder.decode(type.self, from: data)
    }
    
    /// Allows storing of Codable objects to UserDefaults.
    /// - Parameters:
    ///   - object: Codable object to store.
    ///   - key: Identifier of the object.
    ///   - encoder: Custom JSONEncoder instance. Defaults to `JSONEncoder()`.
    func set<T: Codable>(object: T, forKey key: String, usingEncoder encoder: JSONEncoder = JSONEncoder()) {
        let data = try? encoder.encode(object)
        set(data, forKey: key)
    }
}

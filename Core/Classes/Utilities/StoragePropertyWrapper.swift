import Foundation

@propertyWrapper
public struct Storage<T: Codable> {
    private let key: String
    private let defaultValue: T

    public init(key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    public var wrappedValue: T {
        get {
            // Read value from UserDefaults
            guard let data = UserDefaults.standard.object(forKey: key) as? Data else {
                // Return defaultValue when no data in UserDefaults
                return defaultValue
            }
            do {
                // Convert data to the desire data type
                return try JSONDecoder().decode(T.self, from: data)
            } catch {
                return defaultValue
            }
        }
        set {
            do {
                // Convert newValue to data
                let data = try JSONEncoder().pretty().encode(newValue)
                // Set value to UserDefaults
                UserDefaults.standard.set(data, forKey: key)
            } catch {}
        }
    }
}

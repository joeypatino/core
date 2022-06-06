import Foundation

public extension Array where Element == Dictionary<String, Any> {
    /// JSON Data from dictionary.
    /// - Parameter prettify: set true to prettify data (default is false).
    /// - Returns: JSON Data or nil
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// JSON String from dictionary.
    /// - Parameter prettify: set true to prettify string (default is false).
    /// - Returns: JSON String or nil
    func jsonString(prettify: Bool = false) -> String? {
        guard let jsonData = jsonData(prettify: prettify) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
}

public extension Dictionary {
    /// JSON Data from dictionary.
    /// - Parameter prettify: set true to prettify data (default is false).
    /// - Returns: JSON Data or nil
    func jsonData(prettify: Bool = false) -> Data? {
        guard JSONSerialization.isValidJSONObject(self) else {
            return nil
        }
        let options = (prettify == true) ? JSONSerialization.WritingOptions.prettyPrinted : JSONSerialization
            .WritingOptions()
        return try? JSONSerialization.data(withJSONObject: self, options: options)
    }
    
    /// JSON String from dictionary.
    /// - Parameter prettify: set true to prettify string (default is false).
    /// - Returns: JSON String or nil
    func jsonString(prettify: Bool = false) -> String? {
        guard let jsonData = jsonData(prettify: prettify) else { return nil }
        return String(data: jsonData, encoding: .utf8)
    }
    /// Returns a dictionary containing the results of mapping the given closure over the sequence’s elements.
    /// - Parameter transform: A mapping closure. `transform` accepts an element of this sequence as its parameter and returns a transformed value of the same or of a different type.
    /// - Returns: A dictionary containing the transformed elements of this sequence.
    func mapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)) rethrows -> [K: V] {
        return [K: V](uniqueKeysWithValues: try map(transform))
    }
    
    /// Returns a dictionary containing the non-`nil` results of calling the given transformation with each element of this sequence.
    /// - Parameter transform: A closure that accepts an element of this sequence as its argument and returns an optional value.
    /// - Returns: A dictionary of the non-`nil` results of calling `transform` with each element of the sequence.
    /// - Complexity: *O(m + n)*, where _m_ is the length of this sequence and _n_ is the length of the result.
    func compactMapKeysAndValues<K, V>(_ transform: ((key: Key, value: Value)) throws -> (K, V)?) rethrows -> [K: V] {
        return [K: V](uniqueKeysWithValues: try compactMap(transform))
    }
}

public extension Dictionary {
    /// Deep fetch or set a value from nested dictionaries.
    ///     var dict =  ["key": ["key1": ["key2": "value"]]]
    ///     dict[path: ["key", "key1", "key2"]] = "newValue"
    ///     dict[path: ["key", "key1", "key2"]] -> "newValue"
    /// - Note: Value fetching is iterative, while setting is recursive.
    /// - Complexity: O(N), _N_ being the length of the path passed in.
    /// - Parameter path: An array of keys to the desired value.
    /// - Returns: The value for the key-path passed in. `nil` if no value is found.
    subscript(path path: [Key]) -> Any? {
        get {
            guard !path.isEmpty else { return nil }
            var result: Any? = self
            for key in path {
                if let element = (result as? [Key: Any])?[key] {
                    result = element
                } else {
                    return nil
                }
            }
            return result
        }
        set {
            if let first = path.first {
                if path.count == 1, let new = newValue as? Value {
                    return self[first] = new
                }
                if var nested = self[first] as? [Key: Any] {
                    nested[path: Array(path.dropFirst())] = newValue
                    return self[first] = nested as? Value
                }
            }
        }
    }
}

public extension Dictionary {
    /// Merge the keys/values of two dictionaries.
    ///
    ///     let dict: [String: String] = ["key1": "value1"]
    ///     let dict2: [String: String] = ["key2": "value2"]
    ///     let result = dict + dict2
    ///     result["key1"] -> "value1"
    ///     result["key2"] -> "value2"
    ///
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    /// - Returns: An dictionary with keys and values from both.
    static func + (lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
        var result = lhs
        rhs.forEach { result[$0] = $1 }
        return result
    }
    
    /// Append the keys and values from the second dictionary into the first one.
    ///
    ///     var dict: [String: String] = ["key1": "value1"]
    ///     let dict2: [String: String] = ["key2": "value2"]
    ///     dict += dict2
    ///     dict["key1"] -> "value1"
    ///     dict["key2"] -> "value2"
    ///     
    /// - Parameters:
    ///   - lhs: dictionary.
    ///   - rhs: dictionary.
    static func += (lhs: inout [Key: Value], rhs: [Key: Value]) {
        rhs.forEach { lhs[$0] = $1 }
    }
}

import Foundation

public struct Keychain {
    public enum KeychainError: Error {
        case notFound
        case unexpectedData
        case unhandled(status: OSStatus)
    }

    private let serviceId: String
    public init(serviceId: String) {
        self.serviceId = serviceId
    }
    
    public func storeData(_ data: Data, forKey key: String) throws {
        /// drop the object. required for some reason?...
        try remove(forKey: key)

        do {
            _ = try retrieveData(forKey: key)
            var newItem = keychainQuery(withService: serviceId)
            newItem[kSecValueData as String] = data as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandled(status: status) }
        } catch {
            var attributesToUpdate: [String : AnyObject] = [:]
            attributesToUpdate[kSecValueData as String] = data as AnyObject?
            
            let query = keychainQuery(withService: serviceId)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == noErr else { throw KeychainError.unhandled(status: status) }
        }
    }
    
    public func store<M>(_ value: M, for key: String) throws where M: Codable {
        /// drop the object. required for some reason?...
        try remove(forKey: key)

        // Encode the object into
        let encoded = try JSONEncoder().encode(value)
        do {
            // Check for an existing item in the keychain.
            let _: M = try retrieve(forKey: key) as M
            // Update the existing item with the new password.
            var attributesToUpdate: [String : AnyObject] = [:]
            attributesToUpdate[kSecValueData as String] = encoded as AnyObject?
            
            let query = keychainQuery(withService: serviceId)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)
            guard status == noErr else { throw KeychainError.unhandled(status: status) }
            
        } catch KeychainError.notFound {
            var newItem = keychainQuery(withService: serviceId)
            newItem[kSecValueData as String] = encoded as AnyObject?
            
            let status = SecItemAdd(newItem as CFDictionary, nil)
            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandled(status: status) }
        }
    }
    
    public func retrieve<M>(forKey key: String) throws -> M where M: Codable {
        let data = try retrieveData(forKey: key)

        // Parse the value from the query result
        guard let value = try? JSONDecoder().decode(M.self, from: data)
            else { throw KeychainError.unexpectedData }
        
        return value
    }
    
    public func retrieveData(forKey key: String) throws -> Data {
        var query = keychainQuery(withService: serviceId)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue
        
        // Try to fetch the existing keychain item that matches the query
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }
        
        // Check the return status and return if appropriate
        guard status != errSecItemNotFound else { throw KeychainError.notFound }
        guard status == noErr else { throw KeychainError.unhandled(status: status) }
        
        // Parse the value from the query result
        guard let item = queryResult as? [String : AnyObject],
              let data = item[kSecValueData as String] as? Data
        else { throw KeychainError.unexpectedData }
        
        return data
    }
    
    public func remove(forKey key: String) throws {
        // Delete the existing item from the keychain.
        let query = keychainQuery(withService: serviceId)
        let status = SecItemDelete(query as CFDictionary)
        
        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandled(status: status) }
    }
    
    @discardableResult
    public func clear() -> Bool {
        let query = keychainQuery(withService: serviceId)
        let status = SecItemDelete(query as CFDictionary)
        return status == noErr
    }
    
    // MARK: Private
    
    private func keychainQuery(withService service: String, account: String? = nil, accessGroupId: String? = nil) -> [String : AnyObject] {
        var query: [String : AnyObject] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = service as AnyObject?
        
        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }
        
        if let accessGroup = accessGroupId {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }
        
        return query
    }
}

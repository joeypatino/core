import Foundation

public protocol Localizable {
    // Properties for NSLocalizedString function
    var key      : String  { get }
    var tableName: String? { get }
    var bundle   : Bundle  { get }
    var value    : String  { get }
    var comment  : String  { get }
    
    // Property for localizable strings waiting for variables
    var arguments: [CVarArg] { get }
}

// MARK: - Default values of the Localizable protocol properties for the NSLocalizedString function
public extension Localizable {
    var tableName: String? {
        return nil
    }
    var bundle: Bundle {
        return Bundle.main
    }
    var value: String {
        return String()
    }
    var comment: String {
        return String()
    }
}

// MARK: - Localized string property Extraction
public extension Localizable {
    /// Default localized string, helper property
    fileprivate var defaultLocalizedString: String {
        return NSLocalizedString(key, tableName: tableName, bundle: bundle, value: value, comment: comment)
    }
    
    /// Public localized string property extracted
    var localizedString: String {
        return String(format: defaultLocalizedString, arguments: arguments)
    }
}

// MARK: - Default values where RawRepresentable protocol is implemented and RawRepresentable.RawValue == String
public extension Localizable where Self: RawRepresentable, Self.RawValue == String {
    /// Default key value
    var key: String {
        return rawValue
    }
    
    /// Default arguments value
    var arguments: [CVarArg] {
        return []
    }
}

// MARK: - Localized string property Extraction where RawRepresentable protocol is implemented and RawRepresentable.RawValue == String
public extension Localizable where Self: RawRepresentable, Self.RawValue == String {
    /// Localized string extracted
    var localizedString: String {
        return defaultLocalizedString
    }
}

/*
 
 // Example

/// Localization namespace
struct Localization {
    private init() {}
    
    enum Profile: Localizable {
        case title(username: String)
        
        var key: String {
            let key: String
            
            switch self {
            case .title: key = "profile_page_title"
            }
            
            return key
        }
        
        var arguments: [CVarArg] {
            let arguments: [CVarArg]
            
            switch self {
            case let .title(username): arguments = [username]
            }
            
            return arguments
        }
    }
    
    enum Settings: String, Localizable {
        case title = "settings_page_title"
    }
}

 // Usage:

 viewController.title  = Localization.Profile.title(username: "UserName").localizedString
 viewController.title   = Settings.Settings.title.localizedString

*/

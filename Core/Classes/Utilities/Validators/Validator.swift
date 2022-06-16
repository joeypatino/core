import Foundation

public protocol ValidatorType {
    var validationId: String { get }
    var validationHint: String { get }
    init(validationHint: String)
    func isValid(_ input: String) -> Bool
}

public struct Validator: ValidatorType {
    public static var none = Validator(validationHint: "")
    public static var email = EmailValidator(validationHint: Localization.Validators.emailHint.localizedString)
    public static var name = NameValidator(validationHint: Localization.Validators.nameHint.localizedString)
    public static var notEmpty = NotEmptyValidator(validationHint: Localization.Validators.notEmptyHint.localizedString)
    
    public let validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        return true
    }
}

public extension ValidatorType {
    func validate(value: String) -> ValidationResult {
        return isValid(value) ? .valid : .invalid(validationHint)
    }
}

extension ValidatorType {
    static func ==(lhs: ValidatorType, rhs: ValidatorType) -> Bool {
        return lhs.validationId == rhs.validationId
    }
}

public enum ValidationResult {
    case valid
    case invalid(String?)
    
    public var isFailure: Bool {
        if case .invalid = self { return true }
        return false
    }
}

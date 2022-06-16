import Foundation

public struct EmailValidator: ValidatorType {
    private let validator: RegularExpressionValidator
    public let validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        let regEx = "^(([^<>()\\[\\]\\.,;:\\s@\"]+(\\.[^<>()\\[\\]\\.,;:\\s@\"]+)*)|(\".+\"))@((\\[[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}\\.[0-9]{1,3}])|(([a-zA-Z\\-0-9]+\\.)+[a-zA-Z]{2,}))$"
        self.validator = RegularExpressionValidator(regularExpression: regEx)
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        return self.validator.isValid(input) && input.lengthOfBytes(using: .utf8) <= 255
    }
}

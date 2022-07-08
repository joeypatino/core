import Foundation

public struct ZipCodeValidator: ValidatorType {
    private let validator: RegularExpressionValidator
    public let validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        let regEx = "[0-9]{5}"
        self.validator = RegularExpressionValidator(regularExpression: regEx)
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        return self.validator.isValid(input)
    }
}

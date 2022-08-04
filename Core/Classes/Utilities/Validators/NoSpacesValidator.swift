import Foundation

public struct NoSpacesValidator: ValidatorType {
    public let validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        !input.contains(" ")
    }
}

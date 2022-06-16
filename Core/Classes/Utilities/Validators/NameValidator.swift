import Foundation

public struct NameValidator: ValidatorType {
    public var validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        let components = input.components(separatedBy: " ")
        return components.count == 2
    }
}

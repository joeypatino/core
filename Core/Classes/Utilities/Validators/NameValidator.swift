import Foundation

public struct NameValidator: ValidatorType {
    public var validationId: String = UUID().uuidString
    public let validationHint: String
    public init(validationHint: String) {
        self.validationHint = validationHint
    }
    public func isValid(_ input: String) -> Bool {
        let components = input.components(separatedBy: " ").filter { $0.lengthOfBytes(using: .utf8) > 0 }
        return components.count == 2
    }
}

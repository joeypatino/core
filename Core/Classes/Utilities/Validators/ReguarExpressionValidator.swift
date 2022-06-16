import Foundation

public struct RegularExpressionValidator {
    private let regularExpression: String
    public init(regularExpression: String) {
        self.regularExpression = regularExpression
    }
    public func isValid(_ input: String) -> Bool {
        return NSPredicate(format:"SELF MATCHES %@", regularExpression).evaluate(with: input)
    }
}

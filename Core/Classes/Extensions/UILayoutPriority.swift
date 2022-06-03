import UIKit

extension UILayoutPriority: ExpressibleByFloatLiteral, ExpressibleByIntegerLiteral {
    /// Initialize `UILayoutPriority` with a float literal.
    ///
    ///     constraint.priority = 0.5
    ///
    /// - Parameter value: The float value of the constraint.
    public init(floatLiteral value: Float) {
        self.init(rawValue: value)
    }

    /// Initialize `UILayoutPriority` with an integer literal.
    ///
    ///     constraint.priority = 5
    ///
    /// - Parameter value: The integer value of the constraint.
    public init(integerLiteral value: Int) {
        self.init(rawValue: Float(value))
    }
}

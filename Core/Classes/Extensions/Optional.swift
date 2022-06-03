import Foundation

public extension Optional where Wrapped: RawRepresentable, Wrapped.RawValue: Equatable {
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue == rhs
    }

    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func == (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs == rhs?.rawValue
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Optional, rhs: Wrapped.RawValue?) -> Bool {
        return lhs?.rawValue != rhs
    }

    /// Returns a Boolean value indicating whether two values are not equal.
    ///
    /// Inequality is the inverse of equality. For any values `a` and `b`,
    /// `a != b` implies that `a == b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    @inlinable static func != (lhs: Wrapped.RawValue?, rhs: Optional) -> Bool {
        return lhs != rhs?.rawValue
    }
}

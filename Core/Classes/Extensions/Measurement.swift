import Foundation

public extension Measurement where UnitType == UnitAngle {
    /// Create a `Measurement` for an angle with a specified value in degrees.
    /// - Parameter value: The quantity of the angle in degree.
    /// - Returns: Measurement for an angle with unit degrees.
    static func degrees(_ value: Double) -> Measurement {
        return Measurement(value: value, unit: .degrees)
    }
    /// Create a `Measurement` for an angle with a specified value in radians.
    /// - Parameter value: The quantity of the angle in radians.
    /// - Returns: Measurement for an angle with unit radians.
    static func radians(_ value: Double) -> Measurement {
        return Measurement(value: value, unit: .radians)
    }
}

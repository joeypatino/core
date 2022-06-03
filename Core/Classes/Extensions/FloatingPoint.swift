import Foundation

public extension FloatingPoint {
    /// Radian value of degree input.
    var degreesToRadians: Self {
        return Self.pi * self / Self(180)
    }

    /// Degree value of radian input.
    var radiansToDegrees: Self {
        return self * Self(180) / Self.pi
    }
}

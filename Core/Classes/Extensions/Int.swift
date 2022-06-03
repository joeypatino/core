import CoreGraphics

public extension Int {
    /// convert to UInt.
    var uInt: UInt {
        return UInt(self)
    }
    
    /// convert to Double.
    var double: Double {
        return Double(self)
    }

    /// convert to Float.
    var float: Float {
        return Float(self)
    }

    /// convert to CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }

    /// Radian value of degree input
    var degreesToRadians: Double {
        return Double.pi * Double(self) / 180.0
    }

    /// Degree value of radian input
    var radiansToDegrees: Double {
        return Double(self) * 180 / Double.pi
    }
    
    /// Rounds to the closest multiple of n.
    func roundToNearest(_ number: Int) -> Int {
        return number == 0 ? self : Int(round(Double(self) / Double(number))) * number
    }
}

import CoreGraphics

public extension Double {
    /// convert to Int.
    var int: Int {
        return Int(self)
    }
    
    /// convert to Float.
    var float: Float {
        return Float(self)
    }
    
    /// convert to CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
    
    /// convert to NSNumber.
    var number: NSNumber {
        return NSNumber(value: self)
    }
}

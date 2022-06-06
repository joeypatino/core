import CoreGraphics

public extension Float {
    /// conver to Int.
    var int: Int {
        return Int(self)
    }
    
    /// conver to Double.
    var double: Double {
        return Double(self)
    }
    
    /// conver to CGFloat.
    var cgFloat: CGFloat {
        return CGFloat(self)
    }
}

public extension Float64 {
    func truncate(to places : Int)-> Float64 {
        floor(pow(10.0, places.float64) * self)/pow(10.0, places.float64)
    }
}

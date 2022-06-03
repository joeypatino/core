import CoreGraphics

public extension CGRect {
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

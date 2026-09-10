import QuartzCore
import UIKit

public extension CAShapeLayer {
    convenience init(bezierPath: UIBezierPath, fillColor: UIColor, strokeColor: UIColor? = nil) {
        self.init()
        self.bounds = bezierPath.bounds
        self.path = bezierPath.cgPath
        self.fillColor = fillColor.cgColor
        self.strokeColor = strokeColor?.cgColor
    }
}

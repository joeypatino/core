import UIKit

public struct Gradient {
    public enum Direction {
        case bottomToTop
        case topToBottom
        case leftRight
        case rightLeft
        case custom(CGPoint, CGPoint)
    }
    public let startColor: UIColor
    public let endColor: UIColor
    public let colors: [UIColor]
    public let direction: Direction
    public let locations: [Float]
    
    public init(startColor: UIColor, endColor: UIColor, direction: Direction = .bottomToTop, locations: [Float] = [0.0, 1.0]) {
        self.startColor = startColor
        self.endColor = endColor
        self.direction = direction
        self.locations = locations
        self.colors = [startColor, endColor]
    }
    
    public init(colors: [UIColor], direction: Direction = .bottomToTop, locations: [Float] = [0.0, 1.0]) {
        var cls = colors
        if colors.count == 0 {
            cls = [UIColor.clear, UIColor.clear]
        } else if colors.count == 1 {
            cls.append(UIColor.clear)
        }
        self.startColor = cls[0]
        self.endColor = cls[cls.count - 1]
        self.direction = direction
        self.locations = locations
        self.colors = cls
    }
}

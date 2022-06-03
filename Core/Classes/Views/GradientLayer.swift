import UIKit

public final class GradientLayer: CAGradientLayer {
    public override init() {
        super.init()
    }
    
    public init(startColor: UIColor, endColor: UIColor, direction: Gradient.Direction = .bottomToTop, cornerRadius: CGFloat = 0.0, locations: [Float] = [0.0, 1.0]) {
        super.init()
        setGradient(Gradient(startColor: startColor, endColor: endColor, direction: direction, locations: locations), cornerRadius: cornerRadius)
    }
    
    public func setGradient(_ gradient: Gradient, cornerRadius: CGFloat = 0.0) {
        locations = gradient.locations.map { NSNumber(value: $0) }
        colors = gradient.colors.map { $0.cgColor }
        
        switch gradient.direction {
        case .topToBottom:
            startPoint = .init(x: 0.5, y: 0)
            endPoint = .init(x: 0.5, y: 1)
        case .bottomToTop:
            startPoint = .init(x: 0.5, y: 1)
            endPoint = .init(x: 0.5, y: 0)
        case .leftRight:
            startPoint = .init(x: 0, y: 0.5)
            endPoint = .init(x: 1, y: 0.5)
        case .rightLeft:
            startPoint = .init(x: 1, y: 0.5)
            endPoint = .init(x: 0, y: 0.5)
        case .custom(let start, let end):
            startPoint = start
            endPoint = end
        }
        
        self.cornerRadius = cornerRadius
    }
    
    public override init(layer: Any) {
        super.init(layer: layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

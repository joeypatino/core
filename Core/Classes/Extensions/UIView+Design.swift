import UIKit

public extension UIView {
    struct UICornerMask: OptionSet {
        public let rawValue: Int
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
        static public var allCorners: UICornerMask = [.topLeftCorner, .topRightCorner, .bottomLeftCorner, .bottomRightCorner]
        static public var topLeftCorner = UICornerMask(rawValue: 1 << 0)
        static public var topRightCorner = UICornerMask(rawValue: 1 << 1)
        static public var bottomLeftCorner = UICornerMask(rawValue: 1 << 2)
        static public var bottomRightCorner = UICornerMask(rawValue: 1 << 3)
    }
    
    var maskedCorners: UICornerMask {
        get {
            let maskedCorners = layer.maskedCorners
            var corners: UICornerMask = []
            if maskedCorners.contains(.layerMaxXMaxYCorner) {
                corners.insert(.bottomRightCorner)
            }
            if maskedCorners.contains(.layerMinXMaxYCorner) {
                corners.insert(.bottomLeftCorner)
            }
            if maskedCorners.contains(.layerMaxXMinYCorner) {
                corners.insert(.topRightCorner)
            }
            if maskedCorners.contains(.layerMinXMinYCorner) {
                corners.insert(.topLeftCorner)
            }
            return corners
        }
        set {
            var corners: CACornerMask = []
            if newValue.contains(.bottomRightCorner) {
                corners.insert(.layerMaxXMaxYCorner)
            }
            if newValue.contains(.bottomLeftCorner) {
                corners.insert(.layerMinXMaxYCorner)
            }
            if newValue.contains(.topRightCorner) {
                corners.insert(.layerMaxXMinYCorner)
            }
            if newValue.contains(.topLeftCorner) {
                corners.insert(.layerMinXMinYCorner)
            }
            layer.maskedCorners = corners
        }
    }
}

public extension UIView {
    func setBorder(_ color: UIColor, width: CGFloat = 1.0) {
        layer.borderWidth = width
        layer.borderColor = color.cgColor
    }
}

public extension UIView {
    func roundCorners(topLeft: CGFloat = 0, topRight: CGFloat = 0, bottomLeft: CGFloat = 0, bottomRight: CGFloat = 0, borderWidth: CGFloat = 0, borderColor: UIColor? = .clear) {
        let topLeftRadius = CGSize(width: topLeft, height: topLeft)
        let topRightRadius = CGSize(width: topRight, height: topRight)
        let bottomLeftRadius = CGSize(width: bottomLeft, height: bottomLeft)
        let bottomRightRadius = CGSize(width: bottomRight, height: bottomRight)
        let maskPath = UIBezierPath(shouldRoundRect: bounds, topLeftRadius: topLeftRadius, topRightRadius: topRightRadius, bottomLeftRadius: bottomLeftRadius, bottomRightRadius: bottomRightRadius)
        let shape = CAShapeLayer()
        shape.path = maskPath.cgPath
        layer.mask = shape
        
        let borderLayer = CAShapeLayer()
        borderLayer.path = maskPath.cgPath
        borderLayer.lineWidth = borderWidth
        borderLayer.strokeColor = borderColor?.cgColor
        borderLayer.fillColor = UIColor.clear.cgColor
        borderLayer.frame = bounds
        layer.addSublayer(borderLayer)
    }
}

public extension UIView {
    func setLayerCornerRadius(_ radius: CGFloat, maskCorners: UICornerMask = .allCorners) {
        layer.cornerRadius = radius
        maskedCorners = maskCorners
    }
}


public extension UIView {
    func snapshot() -> UIImage {
        UIGraphicsImageRenderer(size: bounds.size).image(actions: { context in
            drawHierarchy(in: bounds, afterScreenUpdates: true)
        })
    }
}

public extension UIView {
    var isVisible: Bool {
        get { !isHidden }
        set { isHidden = !newValue }
    }
}

public extension UIView {
    @objc convenience init(backgroundColor: UIColor) {
        self.init(frame: .zero)
        self.backgroundColor = backgroundColor
    }
}

public extension UIView {
    convenience init(contentMode: UIView.ContentMode) {
        self.init()
        self.contentMode = contentMode
    }
}

public extension UIView {
    /// Make image view blurry.
    /// - Parameter style: UIBlurEffectStyle (default is .light).
    func blur(withStyle style: UIBlurEffect.Style = .light) {
        let blurEffect = UIBlurEffect(style: style)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = bounds
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight] // for supporting device rotation
        addSubview(blurEffectView)
        clipsToBounds = true
    }
    
    /// Blurred version of an image view.
    /// - Parameter style: UIBlurEffectStyle (default is .light).
    /// - Returns: blurred version of self.
    func blurred(withStyle style: UIBlurEffect.Style = .light) -> UIView {
        let view = self
        view.blur(withStyle: style)
        return view
    }
}

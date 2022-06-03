import UIKit

public final class GradientView: UIView {
    public var cornerRadius: CGFloat {
        get { layer.cornerRadius }
        set { layer.cornerRadius = newValue }
    }
    public var isEnabled: Bool = true {
        didSet { gradientLayer?.opacity = isEnabled ? 1.0 : 0.2 }
    }
    
    public override class var layerClass: AnyClass {
        return GradientLayer.self
    }
    private var gradientLayer: GradientLayer? {
        return layer as? GradientLayer
    }
    
    public init(cornerRadius: CGFloat = 0, gradient: Gradient? = nil) {
        super.init(frame: .zero)
        gradient.map { gradientLayer?.setGradient($0, cornerRadius: cornerRadius) }
        self.cornerRadius = cornerRadius
        layout()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        
    }
    
    private func configure() {
        clipsToBounds = true
        layer.masksToBounds = true
    }
}

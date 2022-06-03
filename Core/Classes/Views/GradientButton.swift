import UIKit

public final class GradientButton: UIButton {
    public var title: String? {
        get { title(for: .normal) }
        set { setTitle(newValue, for: .normal) }
    }
    public var titleColor: UIColor {
        get { titleColor(for: .normal) ?? .black }
        set { setTitleColor(newValue, for: .normal) }
    }
    public var titleFont: UIFont? {
        didSet { titleLabel?.font = titleFont }
    }
    public override var isEnabled: Bool {
        didSet { gradient?.opacity = isEnabled ? 1.0 : 0.2 }
    }
    
    private var gradient: GradientLayer?
    
    public init(title: String? = nil, cornerRadius: CGFloat = 0, gradient: Gradient? = nil, contentInsets: UIEdgeInsets = UIEdgeInsets(top: 0, left: 32, bottom: 0, right: 32)) {
        self.gradient = gradient.map { GradientLayer(startColor: $0.startColor, endColor: $0.endColor, direction: $0.direction, cornerRadius: cornerRadius) }
        super.init(frame: .zero)
        self.title = title
        contentEdgeInsets = contentInsets
        layout()
        setup()
        configure()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        gradient?.frame = bounds
        configure()
    }
    
    private func layout() {
        gradient.map {
            layer.insertSublayer($0, at: 0)
            $0.bounds = bounds
        }
        imageView.map { bringSubviewToFront($0) }
    }
    
    private func setup() {
        titleColor = .white
        titleFont = UIFont.systemFont(ofSize: 15.0, weight: .black)
    }
    
    private func configure() {
        imageView?.clipsToBounds = false
        imageView?.layer.masksToBounds = false
        clipsToBounds = false
        layer.masksToBounds = false
    }
    
    func setLayerCornerRadius(_ radius: CGFloat) {
        super.setLayerCornerRadius(radius)
        gradient?.cornerRadius = radius
    }
}

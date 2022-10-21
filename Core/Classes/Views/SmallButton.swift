import UIKit

open class SmallButton: UIButton {
    public var image: UIImage? {
        set { setImage(newValue, for: .normal) }
        get { image(for: .normal) }
    }
    public var insets: CGSize
    public init(image: UIImage? = nil, insets: CGSize = .init(width: 35, height: 35)) {
        self.insets = insets
        super.init(frame: .zero)
        setImage(image, for: .normal)
        clipsToBounds = true
        layer.masksToBounds = true
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let expandedBounds = self.bounds.insetBy(dx: -insets.width, dy: -insets.height)
        return expandedBounds.contains(point)
    }
}

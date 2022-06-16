import UIKit

public class TogglePasswordButton: SmallButton {
    private var wConstraint = NSLayoutConstraint()
    private var hConstraint = NSLayoutConstraint()
    
    public init() {
        super.init(image: UIImage(systemName: "eye.slash"), insets: .init(width: 10, height: 10))
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setImage(UIImage(systemName: "eye"), for: .selected)
        imageView?.clipsToBounds = false
        imageView?.layer.masksToBounds = false
        clipsToBounds = false
        layer.masksToBounds = false
    }
    
    private func layout() {
        
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        NSLayoutConstraint.deactivate([wConstraint, hConstraint])
        wConstraint = widthAnchor.equalToConstant(24)
        hConstraint = heightAnchor.equalToConstant(24)
    }
}

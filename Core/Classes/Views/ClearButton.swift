import UIKit

public final class ClearButton: SmallButton {
    public init() {
        super.init(image: nil, insets: .init(width: 10, height: 10))
        setup()
        layout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        setImage(UIImage(systemName: "xmark.circle"), for: .normal)
        imageView?.clipsToBounds = false
        imageView?.layer.masksToBounds = false
        clipsToBounds = false
        layer.masksToBounds = false
    }
    
    private func layout() {
        heightAnchor.equalToConstant(24)
        widthAnchor.equalTo(heightAnchor)
    }
}

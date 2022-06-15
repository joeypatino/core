import UIKit

public final class Hr: UIView {
    public init(color: UIColor, height: CGFloat = 1.0) {
        super.init(frame: .zero)
        self.backgroundColor = color
        self.heightAnchor.equalToConstant(height)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

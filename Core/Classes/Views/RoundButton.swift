import UIKit

open class RoundButton: UIButton {
    override public init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
        layout()
    }
    
    // MARK: - Overrides
    override open var bounds: CGRect {
        didSet { layer.cornerRadius = bounds.width / 2 }
    }
    
    private func setup() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = bounds.width / 2
    }
    
    private func layout() {
        widthAnchor.equalTo(heightAnchor)
    }
}

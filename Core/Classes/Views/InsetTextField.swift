import UIKit

public class InsetTextField: UITextField {
    public var topPadding:CGFloat = 0
    public var leftPadding:CGFloat = 0
    public var bottomPadding:CGFloat = 0
    public var rightPadding:CGFloat = 0
    
    private var padding:UIEdgeInsets {
        return UIEdgeInsets(top: topPadding,
                            left: leftPadding,
                            bottom: bottomPadding,
                            right: rightPadding)
    }
    
    override public func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    override public func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

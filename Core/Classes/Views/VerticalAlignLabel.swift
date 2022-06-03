import UIKit

public class VerticalyAlignedLabel: UILabel {
    public enum Alignment {
        case top
        case center
        case bottom
    }
    public var verticalTextAlignment: Alignment = .center {
        didSet { self.setNeedsDisplay() }
    }
    
    public var top: Bool = false {
        didSet { self.verticalTextAlignment = top ? .top : .center }
    }

    public var bottom: Bool = false {
        didSet { self.verticalTextAlignment = bottom ? .bottom : .center }
    }
    
    public override func drawText(in rect: CGRect) {
        let actualRect = self.textRect(forBounds: rect, limitedToNumberOfLines: self.numberOfLines)
        super.drawText(in: actualRect)
    }
    
    public override func textRect(forBounds bounds: CGRect, limitedToNumberOfLines numberOfLines: Int) -> CGRect {
        var textRect = super.textRect(forBounds: bounds, limitedToNumberOfLines: numberOfLines)
        switch self.verticalTextAlignment {
        case .top:
            textRect.origin.y = bounds.origin.y
        case .bottom:
            textRect.origin.y = bounds.origin.y + bounds.size.height - textRect.size.height
        default:
            textRect.origin.y = bounds.origin.y + (bounds.size.height - textRect.size.height) * 0.5
            break
        }
        return textRect
    }
}

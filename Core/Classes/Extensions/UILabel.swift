import UIKit

public extension UILabel {
    convenience init(font: UIFont, color: UIColor, alignment: NSTextAlignment = .left, text: String? = nil) {
        self.init()
        self.font = font
        self.textColor = color
        self.textAlignment = alignment
        self.text = text
    }
}

public extension UILabel {
    enum FlipDirection {
        case fromTop
        case fromBottom
        case fromLeft
        case fromRight
        case none
        
        var transition: UIView.AnimationOptions {
            switch self {
            case .none: return .transitionCrossDissolve
            case .fromBottom: return .transitionFlipFromBottom
            case .fromTop: return .transitionFlipFromTop
            case .fromLeft: return .transitionFlipFromLeft
            case .fromRight: return .transitionFlipFromRight
            }
        }
    }
    func setTitle(_ title: NSAttributedString?, duration: TimeInterval = 0.4, direction: FlipDirection = .fromTop, animated: Bool = true) {
        let animate = {
            self.attributedText = title
        }
        UIView.transition(with: self,
                          duration: animated ? duration : 0.0,
                          options: [direction.transition],
                          animations: animate)
    }
    
    func setTitle(_ title: String?, duration: TimeInterval = 0.4, direction: FlipDirection = .fromTop, animated: Bool = true) {
        let animate = {
            self.text = title
        }
        UIView.transition(with: self,
                          duration: animated ? duration : 0.0,
                          options: [direction.transition],
                          animations: animate)
    }
}

public extension UILabel {
    /// Adjust text to fit the label
    /// - Parameters:
    ///   - rect: uses bounds if nil, or skipped
    ///   - maxFont: max font size
    ///   - minFontSize: min font size
    func adjustFontSizeToFit(rect: CGRect? = nil, withMaxFontSize maxFont: CGFloat, minFontSize: CGFloat = 8) {
        guard let text = self.text else {
            return
        }

        let titleSize: CGSize = rect?.size ?? bounds.size
        var testFont: UIFont = self.font
        var index: Int = Int(maxFont)
        while CGFloat(index) > minFontSize {
            // Set the new font size.
            testFont = self.font.withSize(CGFloat(index))
            let constraintSize = CGSize(width: titleSize.width, height: CGFloat.greatestFiniteMagnitude)
            let textRect: CGRect = text.boundingRect(with: constraintSize,
                                                     options: .usesLineFragmentOrigin,
                                                     attributes: [NSAttributedString.Key.font: testFont],
                                                     context: nil)
            let labelSize = textRect.size
            if (labelSize.height) <= titleSize.height {
                break
            }
            index -= 2
        }
        self.font = testFont
    }
}

public extension UILabel {
    func calculateMaxLines() -> Int {
        let maxSize = CGSize(width: frame.size.width, height: CGFloat(Float.infinity))
        let charSize = font.lineHeight
        let text = (self.text ?? "") as NSString
        let textSize = text.boundingRect(with: maxSize, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font as Any], context: nil)
        let linesRoundedUp = Int(ceil(textSize.height/charSize))
        return linesRoundedUp
    }
}

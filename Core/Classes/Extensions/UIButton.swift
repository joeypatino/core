import UIKit

public extension UIButton {
    func setTitle(_ title: String?, forState state: UIControl.State, animated: Bool) {
        guard let titleLabel = self.titleLabel else { return }
        let animate = {
            self.setTitle(title, for: state)
        }
        UIView.transition(with: titleLabel, duration: animated ? 0.4 : 0.0, options: [.transitionFlipFromTop], animations: animate)
    }
}

public extension UIButton {
    func setInsets(
        forContentPadding contentPadding: UIEdgeInsets,
        imageTitlePadding: CGFloat
    ) {
        self.contentEdgeInsets = UIEdgeInsets(
            top: contentPadding.top,
            left: contentPadding.left,
            bottom: contentPadding.bottom,
            right: contentPadding.right + imageTitlePadding
        )
        self.titleEdgeInsets = UIEdgeInsets(
            top: titleEdgeInsets.top,
            left: imageTitlePadding,
            bottom: titleEdgeInsets.bottom,
            right: -imageTitlePadding
        )
    }
}

public extension UIButton {
    func centerTextAndImage(imageAboveText: Bool = false, spacing: CGFloat) {
        if imageAboveText {
            // https://stackoverflow.com/questions/2451223/#7199529
            guard let imageSize = imageView?.image?.size else { return }
            
            let titleSize: CGSize
            if let text = titleLabel?.text,
               let font = titleLabel?.font {
                titleSize = text.size(withAttributes: [.font: font])
            } else if let title = attributedTitle(for: .normal) {
                titleSize = title.size()
            } else {
                return
            }
            let titleOffset = -(imageSize.height + spacing)
            titleEdgeInsets = UIEdgeInsets(top: 0.0, left: -imageSize.width, bottom: titleOffset, right: 0.0)
            
            let imageOffset = -(titleSize.height + spacing)
            imageEdgeInsets = UIEdgeInsets(top: imageOffset, left: 0.0, bottom: 0.0, right: -titleSize.width)
            
            let edgeOffset = abs(titleSize.height - imageSize.height) / 2.0
            contentEdgeInsets = UIEdgeInsets(top: edgeOffset, left: 0.0, bottom: edgeOffset, right: 0.0)
        } else {
            let insetAmount = spacing / 2
            imageEdgeInsets = UIEdgeInsets(top: 0, left: -insetAmount, bottom: 0, right: insetAmount)
            titleEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: -insetAmount)
            contentEdgeInsets = UIEdgeInsets(top: 0, left: insetAmount, bottom: 0, right: insetAmount)
        }
    }
}

public extension UIButton {
    convenience init(tintColor: UIColor) {
        self.init(frame: .zero)
        self.tintColor = tintColor
    }
}

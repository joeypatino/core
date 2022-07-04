import UIKit

public final class TextView: UITextView {
    public let placeholderLabel: UILabel = UILabel()
    public let headerLabel: UILabel = UILabel()
    private var placeholderLabelConstraints = [NSLayoutConstraint]()
    
    public var placeholder: String = "" {
        didSet {
            placeholderLabel.text = placeholder
        }
    }
    public var header: String? {
        didSet {
            headerLabel.text = header
        }
    }
    public var placeholderColor: UIColor = UIColor(red:0.8, green:0.8, blue:0.8, alpha:1) {
        didSet {
            placeholderLabel.textColor = placeholderColor
        }
    }
    public var headerColor: UIColor = UIColor.darkGray {
        didSet {
            headerLabel.textColor = headerColor
        }
    }

    override public var font: UIFont! {
        didSet {
            if placeholderFont == nil {
                placeholderLabel.font = font
            }
        }
    }
    
    public var placeholderFont: UIFont? {
        didSet {
            let font = (placeholderFont != nil) ? placeholderFont : self.font
            placeholderLabel.font = font
        }
    }
    
    public var headerFont: UIFont? {
        didSet {
            let font = (headerFont != nil) ? headerFont : self.font
            headerLabel.font = font
        }
    }
    
    override public var textAlignment: NSTextAlignment {
        didSet {
            placeholderLabel.textAlignment = textAlignment
        }
    }
    
    override public var text: String! {
        didSet {
            textDidChange()
        }
    }
    
    override public var attributedText: NSAttributedString! {
        didSet {
            textDidChange()
        }
    }
    
    override public var textContainerInset: UIEdgeInsets {
        didSet {
            updateConstraintsForPlaceholderLabel()
        }
    }
    
    override public init(frame: CGRect, textContainer: NSTextContainer?) {
        super.init(frame: frame, textContainer: textContainer)
        commonInit()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(textDidChange),
                                               name: UITextView.textDidChangeNotification,
                                               object: nil)
        
        placeholderLabel.font = font
        placeholderLabel.textColor = placeholderColor
        placeholderLabel.textAlignment = textAlignment
        placeholderLabel.text = placeholder
        placeholderLabel.numberOfLines = 0
        placeholderLabel.backgroundColor = UIColor.clear
        placeholderLabel.translatesAutoresizingMaskIntoConstraints = false
        addSubview(placeholderLabel)

        addAutoLayoutSubview(headerLabel)
        headerLabel.topAnchor.equalTo(topAnchor).constant(10)
        headerLabel.leadingAnchor.equalTo(leadingAnchor).constant(16)
        headerLabel.font = headerFont
        headerLabel.textColor = headerColor
        headerLabel.text = header
        
        updateConstraintsForPlaceholderLabel()
        textContainerInset = UIEdgeInsets(top: 0, left: 12, bottom: 12, right: 12)
    }
    
    private func updateConstraintsForPlaceholderLabel() {
        var newConstraints = NSLayoutConstraint.constraints(withVisualFormat: "H:|-(\(textContainerInset.left + textContainer.lineFragmentPadding))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints += NSLayoutConstraint.constraints(withVisualFormat: "V:|-(\(textContainerInset.top))-[placeholder]",
            options: [],
            metrics: nil,
            views: ["placeholder": placeholderLabel])
        newConstraints.append(NSLayoutConstraint(
            item: self,
            attribute: .height,
            relatedBy: .greaterThanOrEqual,
            toItem: placeholderLabel,
            attribute: .height,
            multiplier: 1.0,
            constant: textContainerInset.top + textContainerInset.bottom
        ))
        newConstraints.append(NSLayoutConstraint(
            item: placeholderLabel,
            attribute: .width,
            relatedBy: .equal,
            toItem: self,
            attribute: .width,
            multiplier: 1.0,
            constant: -(textContainerInset.left + textContainerInset.right + textContainer.lineFragmentPadding * 2.0)
        ))
        removeConstraints(placeholderLabelConstraints)
        addConstraints(newConstraints)
        placeholderLabelConstraints = newConstraints
    }
    
    @objc private func textDidChange() {
        placeholderLabel.isHidden = !text.isEmpty
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        placeholderLabel.preferredMaxLayoutWidth = textContainer.size.width - textContainer.lineFragmentPadding * 2.0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self,
                                                  name: UITextView.textDidChangeNotification,
                                                  object: nil)
    }
}

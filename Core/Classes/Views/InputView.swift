import UIKit
import Combine

open class InputView: UIView {
    @Published public var text: String = ""

    public var font: UIFont {
        get { textView.font }
        set { textView.font = newValue }
    }
    public var textColor: UIColor {
        get { textView.textColor }
        set { textView.textColor = newValue }
    }
    
    public var headerColor: UIColor {
        get { textView.headerColor }
        set { textView.headerColor = newValue }
    }
    
    public var placeholder: String {
        get { textView.placeholder }
        set { textView.placeholder = newValue }
    }
    public var placeholderFont: UIFont? {
        get { textView.placeholderFont }
        set { textView.placeholderFont = newValue }
    }
    public var placeholderColor: UIColor {
        get { textView.placeholderColor }
        set { textView.placeholderColor = newValue }
    }
    public var placeholderKern: Float {
        get { textView.placeholderKern }
        set { textView.placeholderKern = newValue }
    }
    
    public var footerFont: UIFont {
        get { footer.font }
        set { footer.font = newValue }
    }
    public var footerTextColor: UIColor {
        get { footer.textColor }
        set { footer.textColor = newValue }
    }
    
    public var focusedBorderColor: UIColor {
        get { textView.focusedBorderColor }
        set { textView.focusedBorderColor = newValue }
    }
    public var focusedHeaderFont: UIFont {
        get { textView.focusedHeaderFont }
        set { textView.focusedHeaderFont = newValue }
    }
    public var focusedBorderWidth: CGFloat {
        get { textView.focusedBorderWidth }
        set { textView.focusedBorderWidth = newValue }
    }
    
    public var unFocusedBorderColor: UIColor {
        get { textView.unFocusedBorderColor }
        set { textView.unFocusedBorderColor = newValue }
    }
    public var unFocusedHeaderFont: UIFont {
        get { textView.unFocusedHeaderFont }
        set { textView.unFocusedHeaderFont = newValue }
    }
    public var unFocusedBorderWidth: CGFloat {
        get { textView.unFocusedBorderWidth }
        set { textView.unFocusedBorderWidth = newValue }
    }
    
    public var borderRadius: CGFloat {
        get { textView.borderRadius }
        set { textView.borderRadius = newValue }
    }
    public var displaysHeader: Bool {
        get { textView.displaysHeader }
        set { textView.displaysHeader = newValue }
    }
    
    public var minimumHeight: CGFloat {
        get { textView.minimumHeight }
        set { textView.minimumHeight = newValue }
    }
    
    private let footer = UILabel(font: .systemFont(ofSize: 12.0, weight: .regular), color: .lightGray)
    internal let textView: InputTextView
    
    public init(headerLabel: UILabel = UILabel(),
                placeholder: String? = nil,
                headerText: String? = nil,
                footerText: String? = nil,
                defaultText: String? = nil) {
        self.textView = InputTextView(headerLabel: headerLabel, header: headerText, placeholder: placeholder, defaultValue: defaultText)
        super.init(frame: .zero)
        footer.text = footerText
        setup()
        layout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textView.delegate = self
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .none
    }
    
    private func layout() {
        let bottom = textView.embed(in: self).bottom
        bottom.isActive = false
        addAutoLayoutSubview(footer)
        footer.topAnchor.equalTo(textView.bottomAnchor).constant(4)
        footer.leadingAnchor.equalTo(leadingAnchor).constant(16)
        footer.trailingAnchor.equalTo(trailingAnchor)
        footer.bottomAnchor.equalTo(bottomAnchor)
    }
}

extension InputView: InputTextViewDelegate {
    public func textFieldDidChange(_ textField: InputTextView) {
        text = textField.text
    }
    public func textFieldDidEndEditing(_ textField: InputTextView) {
        text = textField.text
    }
}

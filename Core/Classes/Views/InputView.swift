import UIKit
import Combine

open class InputView: UIView {
    public weak var delegate: InputTextViewDelegate?
    @Published public var text: String = ""
    @Published public var error: String = ""
    
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
    public var validators: [ValidatorType] {
        get { textView.validators }
        set { textView.validators = newValue }
    }

    public var keyboardType: UIKeyboardType {
        get { textView.keyboardType }
        set { textView.keyboardType = newValue }
    }
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { textView.autocapitalizationType }
        set { textView.autocapitalizationType = newValue }
    }
    public var autocorrectionType: UITextAutocorrectionType {
        get { textView.autocorrectionType }
        set { textView.autocorrectionType = newValue }
    }
    public var spellCheckingType: UITextSpellCheckingType {
        get { textView.spellCheckingType }
        set { textView.spellCheckingType = newValue }
    }
    public var smartQuotesType: UITextSmartQuotesType {
        get { textView.smartQuotesType }
        set { textView.smartQuotesType = newValue }
    }
    public var smartDashesType: UITextSmartDashesType {
        get { textView.smartDashesType }
        set { textView.smartDashesType = newValue }
    }
    public var keyboardAppearance: UIKeyboardAppearance {
        get { textView.keyboardAppearance }
        set { textView.keyboardAppearance = newValue }
    }
    public var returnKeyType: UIReturnKeyType {
        get { textView.returnKeyType }
        set { textView.returnKeyType = newValue }
    }
    
    private let footer = UILabel(font: .systemFont(ofSize: 12.0, weight: .regular), color: .lightGray)
    internal let textView: CoreInputTextView
    
    public init(headerLabel: UILabel = UILabel(),
                placeholder: String? = nil,
                headerText: String? = nil,
                footerText: String? = nil,
                defaultText: String? = nil) {
        self.textView = CoreInputTextView(headerLabel: headerLabel, header: headerText, placeholder: placeholder, defaultValue: defaultText)
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
    
    public func setText(_ text: String?) {
        textView.setText(text.orEmpty)
    }

    public override var isFirstResponder: Bool {
        textView.isFirstResponder
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textView.resignFirstResponder()
    }

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
    /// Invalidates the text input control and configures the visual state. The delegate may also
    /// be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func invalidate() {
        textView.invalidate()
    }
    
    /// Clears the validation state of the text input control and re-configures the visual state.
    /// The delegate may also be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func clearInvalidation() {
        textView.clearInvalidation()
    }
    
    /// Triggers the delegate callback `textInput(_:didUpdateValidation:)` with the current validation
    /// error (if any) by running the currently configured valiation objects for this text input control.
    public func updateValidation() {
        textView.updateValidation()
    }
}

extension InputView: InputTextViewDelegate {
    public func textView(_ textView: CoreInputTextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        delegate?.textView(textView, shouldChangeTextIn: range, replacementText: text) ?? true
    }
    
    public func textViewDidChange(_ textView: CoreInputTextView) {
        text = textView.text
        delegate?.textViewDidChange(textView)
    }
    
    public func textViewDidEndEditing(_ textView: CoreInputTextView) {
        text = textView.text
        delegate?.textViewDidEndEditing(textView)
    }
    
    public func textView(_ textView: CoreInputTextView, didUpdateValidation error: String?) {
        guard let error = error else {
            self.error = ""
            delegate?.textView(textView, didUpdateValidation: error)
            return
        }
        self.error = error
        delegate?.textView(textView, didUpdateValidation: error)
    }
}

import UIKit
import Combine

open class InputField: UIView {
    @Published public var text: String = ""
    @Published public var error: String = ""
    
    public weak var delegate: InputTextFieldDelegate? {
        get { textField.delegate }
        set { textField.delegate = newValue }
    }

    public var font: UIFont {
        get { textField.font }
        set { textField.font = newValue }
    }
    public var textColor: UIColor {
        get { textField.textColor }
        set { textField.textColor = newValue }
    }
    
    public var headerColor: UIColor {
        get { textField.headerColor }
        set { textField.headerColor = newValue }
    }
    
    public var placeholder: String {
        get { textField.placeholder }
        set { textField.placeholder = newValue }
    }
    public var placeholderFont: UIFont? {
        get { textField.placeholderFont }
        set { textField.placeholderFont = newValue }
    }
    public var placeholderColor: UIColor {
        get { textField.placeholderColor }
        set { textField.placeholderColor = newValue }
    }
    public var placeholderKern: Float {
        get { textField.placeholderKern }
        set { textField.placeholderKern = newValue }
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
        get { textField.focusedBorderColor }
        set { textField.focusedBorderColor = newValue }
    }
    public var focusedHeaderFont: UIFont {
        get { textField.focusedHeaderFont }
        set { textField.focusedHeaderFont = newValue }
    }
    public var focusedBorderWidth: CGFloat {
        get { textField.focusedBorderWidth }
        set { textField.focusedBorderWidth = newValue }
    }
    
    public var unFocusedBorderColor: UIColor {
        get { textField.unFocusedBorderColor }
        set { textField.unFocusedBorderColor = newValue }
    }
    public var unFocusedHeaderFont: UIFont {
        get { textField.unFocusedHeaderFont }
        set { textField.unFocusedHeaderFont = newValue }
    }
    public var unFocusedBorderWidth: CGFloat {
        get { textField.unFocusedBorderWidth }
        set { textField.unFocusedBorderWidth = newValue }
    }
    
    public var borderRadius: CGFloat {
        get { textField.borderRadius }
        set { textField.borderRadius = newValue }
    }
    public var displaysHeader: Bool {
        get { textField.displaysHeader }
        set { textField.displaysHeader = newValue }
    }
    public var minimumHeight: CGFloat {
        get { textField.minimumHeight }
        set { textField.minimumHeight = newValue }
    }
    public var validators: [ValidatorType] {
        get { textField.validators }
        set { textField.validators = newValue }
    }
    
    public var keyboardType: UIKeyboardType {
        get { textField.keyboardType }
        set { textField.keyboardType = newValue }
    }
    public var autocapitalizationType: UITextAutocapitalizationType {
        get { textField.autocapitalizationType }
        set { textField.autocapitalizationType = newValue }
    }
    public var autocorrectionType: UITextAutocorrectionType {
        get { textField.autocorrectionType }
        set { textField.autocorrectionType = newValue }
    }
    public var spellCheckingType: UITextSpellCheckingType {
        get { textField.spellCheckingType }
        set { textField.spellCheckingType = newValue }
    }
    public var smartQuotesType: UITextSmartQuotesType {
        get { textField.smartQuotesType }
        set { textField.smartQuotesType = newValue }
    }
    public var smartDashesType: UITextSmartDashesType {
        get { textField.smartDashesType }
        set { textField.smartDashesType = newValue }
    }
    public var keyboardAppearance: UIKeyboardAppearance {
        get { textField.keyboardAppearance }
        set { textField.keyboardAppearance = newValue }
    }
    public var returnKeyType: UIReturnKeyType {
        get { textField.returnKeyType }
        set { textField.returnKeyType = newValue }
    }
    
    public var accessoryPresentationDirection: InputTextField.AccessoryPresentationDirection {
        get { textField.accessoryPresentationDirection }
        set { textField.accessoryPresentationDirection = newValue }
    }
    
    public var insets: UIEdgeInsets {
        get { textField.insets }
        set { textField.insets = newValue }
    }
    
    private var textInsetLeft = NSLayoutConstraint()
    private var textInsetTop = NSLayoutConstraint()
    private var textInsetRight = NSLayoutConstraint()
    private var textInsetBottom = NSLayoutConstraint()
    
    private let footer = UILabel(font: .systemFont(ofSize: 12.0, weight: .regular), color: .lightGray)
    internal let textField: InputTextField
    
    public init(headerLabel: UILabel = UILabel(),
                placeholder: String? = nil,
                headerText: String? = nil,
                footerText: String? = nil,
                defaultText: String? = nil) {
        self.textField = InputTextField(headerLabel: headerLabel, header: headerText, placeholder: placeholder, defaultValue: defaultText)
        super.init(frame: .zero)
        footer.text = footerText
        setup()
        layout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
    }
    
    private func layout() {
        let bottom = textField.embed(in: self).bottom
        bottom.isActive = false
        addAutoLayoutSubview(footer)
        footer.topAnchor.equalTo(textField.bottomAnchor).constant(4)
        footer.leadingAnchor.equalTo(leadingAnchor).constant(16)
        footer.trailingAnchor.equalTo(trailingAnchor)
        footer.bottomAnchor.equalTo(bottomAnchor)
    }
    
    public func setText(_ text: String?) {
        textField.setText(text.orEmpty)
    }
    
    public func setAccessoryView(_ height: CGFloat) {
        textField.setAccessoryView(height)
    }
    
    public func setAccessoryView(_ view: UIView) {
        textField.setAccessoryView(view)
    }
    
    public override var isFirstResponder: Bool {
        textField.isFirstResponder
    }

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    @discardableResult
    open override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if textField.point(inside: point, with: event) { return true }
        else { return super.point(inside: point, with: event) }
    }
    
    /// Invalidates the text input control and configures the visual state. The delegate may also
    /// be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func invalidate() {
        textField.invalidate()
    }
    
    /// Clears the validation state of the text input control and re-configures the visual state.
    /// The delegate may also be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func clearInvalidation() {
        textField.clearInvalidation()
    }
    
    /// Triggers the delegate callback `textInput(_:didUpdateValidation:)` with the current validation
    /// error (if any) by running the currently configured valiation objects for this text input control.
    public func updateValidation() {
        textField.updateValidation()
    }
}

extension InputField: InputTextFieldDelegate {
    public func textFieldDidChange(_ textField: InputTextField) {
        text = textField.text
    }
    public func textFieldDidEndEditing(_ textField: InputTextField) {
        text = textField.text
    }
    public func textField(_ textField: InputTextField, didUpdateValidation error: String?) {
        guard let error = error else {
            self.error = ""
            return
        }
        self.error = error
    }
}

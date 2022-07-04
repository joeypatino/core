import UIKit

public protocol InputTextFieldDelegate: AnyObject {
    func textFieldDidBeginEditing(_ textField: InputTextField)
    func textFieldDidChange(_ textField: InputTextField)
    func textFieldDidEndEditing(_ textField: InputTextField)
}

extension InputTextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: InputTextField) {}
    public func textFieldDidChange(_ textField: InputTextField) {}
    public func textFieldDidEndEditing(_ textField: InputTextField) {}
}

public final class InputTextField: UIView {
    public enum FocusStyle {
        case unfocused
        case focused
    }
    public enum ClearButtonMode {
        case alwaysVisible
        case whenContentAvailable
    }
    public var minimumHeight: CGFloat = 64 {
        didSet { updateHeight() }
    }
    public weak var delegate: InputTextFieldDelegate?
    
    public var text: String {
        get { textField.text.orEmpty }
        set { textField.text = newValue; updateClearButton() }
    }
    public var placeholder: String {
        get { textField.placeholder.orEmpty }
        set { textField.placeholder = newValue; updatePlaceholder() }
    }
    public var placeholderFont: UIFont? {
        didSet { updatePlaceholder() }
    }
    public var placeholderColor: UIColor = UIColor.gray.withAlphaComponent(0.7) {
        didSet { updatePlaceholder() }
    }
    public var placeholderKern: Float = 0.0 {
        didSet { updatePlaceholder() }
    }
    public var clearButtonMode: ClearButtonMode = .alwaysVisible
    
    public var font: UIFont {
        get { textField.font ?? .systemFont(ofSize: 14.0, weight: .semibold) }
        set { textField.font = newValue }
    }
    public var textColor: UIColor {
        get { textField.textColor ?? UIColor.white }
        set { textField.textColor = newValue }
    }
    public var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set {
            textField.isSecureTextEntry = newValue
            updateSecureText()
        }
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
    public var displaysHeader: Bool = true {
        didSet { textTopConstraint.isActive = !displaysHeader }
    }
    public var insets: UIEdgeInsets = UIEdgeInsets(top: 2, left: 0, bottom: 12, right: 0) {
        didSet {
            insetsTopConstraint.constant(insets.top)
            insetsLeftConstraint.constant(insets.left)
            insetsRightConstraint.constant(-insets.right)
            insetsBottomConstraint.constant(-insets.bottom)
        }
    }
    
    public var focusedBorderColor: UIColor = .white {
        didSet { updateBorder() }
    }
    public var unFocusedBorderColor: UIColor = .darkGray {
        didSet { updateBorder() }
    }
    public var headerColor: UIColor = .lightGray {
        didSet { updateHeader() }
    }
    public var headerFont: UIFont {
        headerStyle == .focused ? focusedHeaderFont : unFocusedHeaderFont
    }
    public var focusedHeaderFont: UIFont = .systemFont(ofSize: 12.0, weight: .regular) {
        didSet { updateHeader() }
    }
    public var unFocusedHeaderFont: UIFont = .systemFont(ofSize: 14.0, weight: .semibold) {
        didSet { updateHeader() }
    }
    public var focusedBorderWidth: CGFloat = 1 {
        didSet { updateBorder() }
    }
    public var unFocusedBorderWidth: CGFloat = 1 {
        didSet { updateBorder() }
    }
    public var borderRadius: CGFloat = 16 {
        didSet { updateBorder() }
    }
    
    public var leftView: UIView? {
        get { textField.leftView }
        set { textField.leftView = newValue; textField.leftViewMode = .always }
    }
    
    public var leftViewMode: UITextField.ViewMode {
        get { textField.leftViewMode }
        set { textField.leftViewMode = newValue }
    }
    
    public var absoluteTextInsets: UIEdgeInsets {
        get { textField.insets }
        set { textField.insets = newValue }
    }
    
    private var focusedHeaderOffset: CGPoint = .init(x: 16, y: 12)
    private var unFocusedHeaderOffset: CGPoint = .init(x: 16, y: 20)
    private var borderWidth: CGFloat {
        borderStyle == .focused ? focusedBorderWidth : unFocusedBorderWidth
    }
    private var headerOffset: CGPoint {
        headerStyle == .focused ? focusedHeaderOffset : unFocusedHeaderOffset
    }

    private let textField = TextField()
    private let header: UILabel
    private let stack = UIStackView(axis: .horizontal)
    private var borderStyle: FocusStyle = .unfocused {
        didSet { updateBorder() }
    }
    private var headerStyle: FocusStyle = .unfocused {
        didSet { updateHeader() }
    }
    private var stackHeightConstraint = NSLayoutConstraint()
    private var minHeightConstraint = NSLayoutConstraint()
    private var headerLeadingConstraint = NSLayoutConstraint()
    private var headerTopHeightConstraint = NSLayoutConstraint()
    private var headerCenterYConstraint = NSLayoutConstraint()
    private var textTopConstraint = NSLayoutConstraint()
    
    private var insetsTopConstraint = NSLayoutConstraint()
    private var insetsRightConstraint = NSLayoutConstraint()
    private var insetsLeftConstraint = NSLayoutConstraint()
    private var insetsBottomConstraint = NSLayoutConstraint()
    
    public init(headerLabel: UILabel = UILabel(), header: String? = nil, placeholder: String? = nil, defaultValue: String? = nil) {
        self.header = headerLabel
        self.header.text = header
        self.textField.text = defaultValue
        super.init(frame: .zero)
        self.placeholder = placeholder.orEmpty
        displaysHeader = header?.isEmpty == false
        setup()
        layout()
        updateFocusStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
        
    public override func updateConstraints() {
        super.updateConstraints()
        removeConstraint(minHeightConstraint)
        minHeightConstraint = heightAnchor.equalToConstant(minimumHeight)
    }
    
    public override var canBecomeFirstResponder: Bool {
        textField.canBecomeFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        textField.becomeFirstResponder()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
    }
    
    private func updateFocusStyle() {
        borderStyle = .unfocused
        headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
    }

    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        stack.alignment = .center
        stack.spacing = 14
        stack.addArrangedSubview(Spacer(orientation: .horizonal(width: 0)))
        textField.textColor = textColor
        textField.font = font
        textField.delegate = self
        
        updateClearButton()
    }
    
    private func layout() {
        addAutoLayoutSubview(stack)
        stack.topAnchor.equalTo(topAnchor)
        stack.trailingAnchor.equalTo(trailingAnchor).constant(-16)
        stackHeightConstraint = stack.heightAnchor.equalToConstant(minimumHeight)

        addAutoLayoutSubview(header)
        headerTopHeightConstraint = header.topAnchor.equalTo(topAnchor).constant(headerOffset.y)
        headerLeadingConstraint = header.leadingAnchor.equalTo(leadingAnchor).constant(headerOffset.x)
        header.widthAnchor.equalTo(widthAnchor, multiplier: 0.5)
        headerCenterYConstraint = header.centerYAnchor.equalTo(centerYAnchor)
        headerCenterYConstraint.isActive = false

        addAutoLayoutSubview(textField)
        textTopConstraint = textField.topAnchor.equalTo(topAnchor).constant(12)
        textTopConstraint.isActive = !displaysHeader
        
        insetsTopConstraint = textField.topAnchor.equalTo(header.bottomAnchor, priority: 999).constant(insets.top)
        insetsLeftConstraint = textField.leadingAnchor.equalTo(header.leadingAnchor).constant(insets.left)
        insetsRightConstraint = textField.trailingAnchor.equalTo(stack.leadingAnchor).constant(-insets.right)
        insetsBottomConstraint = textField.bottomAnchor.equalTo(bottomAnchor).constant(-insets.bottom)
        
        updateBorder()
        updateHeader()
    }
    
    private func updateBorder() {
        layer.borderWidth = borderWidth
        layer.cornerRadius = borderRadius
        layer.borderColor = borderStyle == .focused ? focusedBorderColor.cgColor : unFocusedBorderColor.cgColor
    }
    
    private func updateHeader() {
        header.textColor = headerColor
        header.font = headerFont
        headerTopHeightConstraint.constant = headerOffset.y
        headerLeadingConstraint.constant = headerOffset.x
        switch headerStyle {
        case .unfocused:
            headerTopHeightConstraint.isActive = false
            headerCenterYConstraint.isActive = true
        case .focused:
            headerCenterYConstraint.isActive = false
            headerTopHeightConstraint.isActive = true
        }
    }
    
    private func updateHeight() {
        stackHeightConstraint.constant = minimumHeight
        minHeightConstraint.constant = minimumHeight
    }

    public func setText(_ text: String) {
        self.text = text
        self.headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
        self.delegate?.textFieldDidChange(self)
        updateClearButton()
    }
    
    public func addAccessoryView(_ view: UIView) {
        stack.addArrangedSubview(view)
        updateClearButton()
    }
    
    private func updateSecureText() {
        if let existingSelectedTextRange = textField.selectedTextRange {
            textField.selectedTextRange = nil
            textField.selectedTextRange = existingSelectedTextRange
        }
        
        updateClearButton()
    }
    
    private func updatePlaceholder() {
        let attrs: [NSAttributedString.Key: Any] = [.font: placeholderFont ?? font,
                                                    .foregroundColor: placeholderColor,
                                                    .kern: placeholderKern]
        textField.attributedPlaceholder = NSAttributedString(string: (textField.placeholder ?? ""), attributes: attrs)
    }
    
    private func updateClearButton() {
        switch clearButtonMode {
        case .alwaysVisible:
            stack.isHidden = false
        case .whenContentAvailable:
            stack.isHidden = !self.textField.hasText
        }
    }
}

extension InputTextField: UITextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        delegate?.textFieldDidBeginEditing(self)
        self.borderStyle = .focused
        self.headerStyle = .focused
        let animations = { self.layoutIfNeeded() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }
    
    public func textFieldDidEndEditing(_ textField: UITextField) {
        delegate?.textFieldDidEndEditing(self)
        self.borderStyle = .unfocused
        self.headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
        let animations = { self.layoutIfNeeded() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        delegate?.textFieldDidChange(self)
        
        updateClearButton()
    }
    
    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

internal class TextField: UITextField {
    public var insets: UIEdgeInsets = .zero {
        didSet { setNeedsDisplay() }
    }
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        super.textRect(forBounds: bounds).inset(by: insets)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        super.editingRect(forBounds: bounds).inset(by: insets)
    }
}

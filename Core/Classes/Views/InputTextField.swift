import UIKit

// actions that occur during interaction with the InputTextField
struct InputTextFieldAction: OptionSet {
    let rawValue: Int

    static let didFocus = InputTextFieldAction(rawValue: 1 << 0)
    static let endFocus = InputTextFieldAction(rawValue: 1 << 1)
    static let edit     = InputTextFieldAction(rawValue: 1 << 2)
}


public protocol InputTextFieldDelegate: AnyObject {
    func textFieldDidBeginEditing(_ textField: InputTextField)
    func textFieldDidChange(_ textField: InputTextField)
    func textFieldDidEndEditing(_ textField: InputTextField)
    func textFieldDidReturn(_ textField: InputTextField)
    func textField(_ textField: InputTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool
    func textField(_ textField: InputTextField, didChangeFocus isFocused: Bool)
    func textField(_ textField: InputTextField, didUpdateValidation error: String?)
}

extension InputTextFieldDelegate {
    public func textFieldDidBeginEditing(_ textField: InputTextField) {}
    public func textFieldDidChange(_ textField: InputTextField) {}
    public func textFieldDidEndEditing(_ textField: InputTextField) {}
    public func textFieldDidReturn(_ textField: InputTextField) {}
    public func textField(_ textField: InputTextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool { true }
    public func textField(_ textField: InputTextField, didChangeFocus isFocused: Bool) {}
    public func textField(_ textField: InputTextField, didUpdateValidation error: String?) {}
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
    public enum AccessoryPresentationDirection: String {
        case up
        case down
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
    public var accessoryPresentationDirection: AccessoryPresentationDirection = .down {
        didSet {
            switch accessoryPresentationDirection {
            case .up:
                accessoryPresentationConstraints[.down]?.forEach { $0.isActive = false }
                accessoryPresentationConstraints[.up]?.forEach { $0.isActive = true }
            case .down:
                accessoryPresentationConstraints[.up]?.forEach { $0.isActive = false }
                accessoryPresentationConstraints[.down]?.forEach { $0.isActive = true }
            }
        }
    }
    
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
    
    /// the validators for this text input
    public var validators: [ValidatorType] = []
    
    /// is paste enabled?
    public var canPaste: Bool {
        get { textField.canPaste }
        set { textField.canPaste = newValue }
    }
    
    /// is copy enabled?
    public var canCopy: Bool {
        get { textField.canCopy }
        set { textField.canCopy = newValue }
    }
    
    /// The beginning of the the text document
    public var beginningOfDocument: UITextPosition { textField.beginningOfDocument }
    
    /// Text may have a selection, either zero-length (a caret) or ranged.  Editing operations are
    /// always performed on the text from this selection.  nil corresponds to no selection
    public var selectedTextRange: UITextRange? {
        get { textField.selectedTextRange }
        set { textField.selectedTextRange = newValue }
    }
    
    // the current set of editing actions this control has taken
    private var editActions: InputTextFieldAction = []
    
    /// tracks the first time we resign the keyboard
    private var didEdit: Bool = false
    
    /// temporary invalidation state
    private var isMarkedInvalid: Bool = false

    private var focusedHeaderOffset: CGPoint = .init(x: 16, y: 12)
    private var unFocusedHeaderOffset: CGPoint = .init(x: 16, y: 20)
    private var borderWidth: CGFloat {
        borderStyle == .focused ? focusedBorderWidth : unFocusedBorderWidth
    }
    private var borderColor: UIColor {
        borderStyle == .focused ? focusedBorderColor : unFocusedBorderColor
    }
    private var headerOffset: CGPoint {
        headerStyle == .focused ? focusedHeaderOffset : unFocusedHeaderOffset
    }
    /// the backing view is used to display the border when the accessory view is in the expanded state
    private lazy var accessoryBackingView = UIView(backgroundColor: .clear)
    /// the accessory content view container
    private lazy var accessoryContentView = UIView(backgroundColor: .white)
    /// the height constraint for the accessory content view container
    private lazy var accessoryViewConstraint = NSLayoutConstraint()
    
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
    private var accessoryPresentationConstraints: [AccessoryPresentationDirection: [NSLayoutConstraint]] = [:]
    
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

    @discardableResult
    public override func resignFirstResponder() -> Bool {
        textField.resignFirstResponder()
    }

    public override var isFirstResponder: Bool {
        textField.isFirstResponder
    }
    
    public override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let translatedPoint = accessoryContentView.convert(point, from: self)
        if accessoryContentView.bounds.contains(translatedPoint) {
            return accessoryContentView.hitTest(translatedPoint, with: event)
        }
        return super.hitTest(point, with: event)
    }

    public override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        if accessoryContentView.frame.contains(point) {
            return true
        }
        return super.point(inside: point, with: event)
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textField.becomeFirstResponder()
    }
    
    public func position(from position: UITextPosition, offset: Int) -> UITextPosition? {
        textField.position(from: position, offset: offset)
    }
    
    public func textRange(from fromPosition: UITextPosition, to toPosition: UITextPosition) -> UITextRange? {
        textField.textRange(from: fromPosition, to: toPosition)
    }

    public func setText(_ text: String) {
        self.text = text
        self.headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
        self.delegate?.textFieldDidChange(self)
        self.updateValidationIfNeeded()
    }
    
    /// Invalidates the text input control and configures the visual state. The delegate may also
    /// be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func invalidate() {
        guard !isMarkedInvalid else { return }
        isMarkedInvalid = true
        updateValidationIfNeeded()
    }
    
    /// Clears the validation state of the text input control and re-configures the visual state.
    /// The delegate may also be called `textInput(_:didUpdateValidation:)` depending on the current editing state
    public func clearInvalidation() {
        guard isMarkedInvalid else { return }
        isMarkedInvalid = false
        updateValidationIfNeeded()
    }
    
    /// Triggers the delegate callback `textInput(_:didUpdateValidation:)` with the current validation
    /// error (if any) by running the currently configured valiation objects for this text input control.
    public func updateValidation() {
        delegate?.textField(self, didUpdateValidation: validationError())
    }
    
    private func updateFocusStyle() {
        borderStyle = .unfocused
        headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
    }
    
    private func setup() {
        NotificationCenter.default.addObserver(self, selector: #selector(textFieldDidChange(_:)), name: UITextField.textDidChangeNotification, object: textField)
        stack.alignment = .center
        stack.spacing = 14
        textField.textColor = textColor
        textField.font = font
        textField.delegate = self
        
        accessoryContentView.setLayerCornerRadius(borderRadius, maskCorners: [.bottomLeftCorner, .bottomRightCorner])
        accessoryBackingView.setBorder(focusedBorderColor, width: focusedBorderWidth)
        
        updateClearButton()
    }
    
    private func layout() {
        accessibilityIdentifier = "InputField"
        stack.accessibilityIdentifier = "InputField.Stack"
        header.accessibilityIdentifier = "InputField.Header"
        textField.accessibilityIdentifier = "InputField.TextField"
        accessoryContentView.accessibilityIdentifier = "InputField.Accessory.ContentView"
        accessoryBackingView.accessibilityIdentifier = "InputField.Accessory.BackingView"
        
        addAccessoryConstraints()

        addAutoLayoutSubview(stack)
        stack.topAnchor.equalTo(topAnchor)
        stack.trailingAnchor.equalTo(trailingAnchor, priority: 999).constant(-16)
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
    
    private func removeAccessoryConstraints() {
        accessoryPresentationConstraints.removeAll()
        accessoryContentView.removeFromSuperview()
        accessoryBackingView.removeFromSuperview()
    }
    
    private func addAccessoryConstraints() {
        removeAccessoryConstraints()

        addAutoLayoutSubview(accessoryContentView)
        sendSubviewToBack(accessoryContentView)
        var accessoryPresentationUpConstraints = [NSLayoutConstraint]()
        var accessoryPresentationDownConstraints = [NSLayoutConstraint]()
        accessoryPresentationUpConstraints = [
            accessoryContentView.leadingAnchor.equalTo(leadingAnchor).setIsActive(false),
            accessoryContentView.trailingAnchor.equalTo(trailingAnchor).setIsActive(false),
            accessoryContentView.bottomAnchor.equalTo(topAnchor).constant(focusedBorderWidth).setIsActive(false)
        ]
        accessoryPresentationDownConstraints = [
            accessoryContentView.leadingAnchor.equalTo(leadingAnchor).setIsActive(false),
            accessoryContentView.trailingAnchor.equalTo(trailingAnchor).setIsActive(false),
            accessoryContentView.topAnchor.equalTo(bottomAnchor).constant(-focusedBorderWidth).setIsActive(false)
        ]
        
        addAutoLayoutSubview(accessoryBackingView)
        sendSubviewToBack(accessoryBackingView)

        accessoryPresentationUpConstraints += [
            accessoryBackingView.topAnchor.equalTo(accessoryContentView.topAnchor).constant(-focusedBorderWidth*2).setIsActive(false),
            accessoryBackingView.leadingAnchor.equalTo(leadingAnchor).constant(-focusedBorderWidth).setIsActive(false),
            accessoryBackingView.trailingAnchor.equalTo(trailingAnchor).constant(focusedBorderWidth).setIsActive(false),
            accessoryBackingView.bottomAnchor.equalTo(bottomAnchor).constant(focusedBorderWidth).setIsActive(false)
        ]
        accessoryPresentationDownConstraints += [
            accessoryBackingView.topAnchor.equalTo(topAnchor).constant(-focusedBorderWidth).setIsActive(false),
            accessoryBackingView.bottomAnchor.equalTo(accessoryContentView.bottomAnchor).constant(focusedBorderWidth*2).setIsActive(false),
            accessoryBackingView.leadingAnchor.equalTo(leadingAnchor).constant(-focusedBorderWidth).setIsActive(false),
            accessoryBackingView.trailingAnchor.equalTo(trailingAnchor).constant(focusedBorderWidth).setIsActive(false)
        ]
        accessoryPresentationConstraints[.up] = accessoryPresentationUpConstraints
        accessoryPresentationConstraints[.down] = accessoryPresentationDownConstraints
        
        switch accessoryPresentationDirection {
        case .up:
            accessoryPresentationConstraints[.up]?.forEach { $0.isActive = true }
        case .down:
            accessoryPresentationConstraints[.down]?.forEach { $0.isActive = true }
        }
    }
    
    private func updateBorder() {
        if textField.isFirstResponder {
  
            layer.borderColor = UIColor.clear.cgColor
            accessoryBackingView.layer.borderColor = (isInvalid() || isMarkedInvalid)
            ? UIColor(hex: "#BA2639").cgColor
            : borderColor.cgColor
            
        } else {
            layer.borderColor = (isInvalid() || isMarkedInvalid)
            ? UIColor(hex: "#BA2639").cgColor
            : borderColor.cgColor
            accessoryBackingView.layer.borderColor = UIColor.clear.cgColor
        }

        layer.cornerRadius = borderRadius
        layer.borderWidth = borderWidth
        accessoryBackingView.layer.borderWidth = borderWidth
        accessoryContentView.setLayerCornerRadius(borderRadius, maskCorners: [.bottomLeftCorner, .bottomRightCorner])
        accessoryBackingView.setLayerCornerRadius(borderRadius, maskCorners: .allCorners)
        
        addAccessoryConstraints()
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

    private func updateText(_ text: String) {
        // this method forces the text to be displayed, and thus should be considered an "editing" action
        didEdit = true
        // set the text
        textField.text = text
        // and update the validation state
        updateValidationIfNeeded()
    }

    private func updateValidationIfNeeded() {
        updateBorder()
        /// only notify regarding the validation error if we've ended the focus AND have edited the text
        guard editActions.contains(.edit) else { return }
        delegate?.textField(self, didUpdateValidation: validationError())
    }
    
    private func validationError() -> String? {
        let validators = validators
        return validators.filter { !$0.isValid(textField.text ?? "") }.first?.validationHint
    }
    
    private func isInvalid() -> Bool {
        guard didEdit else { return false }
        let failedValidators = validators.filter { !$0.isValid(textField.text ?? "") }
        if let _ = failedValidators.first?.validationHint {
            return true
        }
        return false
    }
    
    private func setIsFocusedIfAllowed(_ focused: Bool, animated: Bool = true) {
        if focused {
            // if we've not yet edited the text, then pretend we did not perform this focus / unfocus event
            // this logic will prevent the validation delegate callback from being triggered unless an edit actually occurs
            if !editActions.contains(.edit) { editActions.remove(.endFocus) }
        } else {
            editActions.insert(.endFocus)
        }
        delegate?.textField(self, didChangeFocus: focused)
        updateValidationIfNeeded()
    }
}

extension InputTextField: UITextFieldDelegate {
    @objc private func textFieldDidChange(_ textField: UITextField) {
        editActions.insert(.edit)
        delegate?.textFieldDidChange(self)
        updateValidationIfNeeded()
        updateClearButton()
    }
    
    public func textFieldDidBeginEditing(_ textField: UITextField) {
        isMarkedInvalid = false
        setIsFocusedIfAllowed(true)

        delegate?.textFieldDidBeginEditing(self)
        self.borderStyle = .focused
        self.headerStyle = .focused
        let animations = { self.setNeedsLayout() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }

    public func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.isEmpty == false { didEdit = true }
        setIsFocusedIfAllowed(false)

        delegate?.textFieldDidEndEditing(self)
        self.borderStyle = .unfocused
        self.headerStyle = textField.text.orEmpty.isEmpty ? .unfocused : .focused
        let animations = { self.setNeedsLayout() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }
    
    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        delegate?.textField(self, shouldChangeCharactersIn: range, replacementString: string) ?? true
    }

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        delegate?.textFieldDidReturn(self)
        return true
    }
}

extension InputTextField {
    public func setAccessoryView(_ height: CGFloat) {
        accessoryViewConstraint.isActive = false
        accessoryViewConstraint = accessoryContentView.heightAnchor.equalToConstant(height)
        let animations = { self.setNeedsLayout() }
        UIView.animate(withDuration: 0.3, animations: animations)
    }
    
    public func setAccessoryView(_ view: UIView) {
        accessoryContentView.subviews.forEach { $0.removeFromSuperview() }
        view.layer.cornerRadius = borderRadius
        view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        view.embed(in: accessoryContentView, inset: UIEdgeInsets(top: 0, left: borderWidth, bottom: 0, right: borderWidth))
    }
}

internal class TextField: UITextField {
    public var canPaste: Bool = true
    public var canCopy: Bool = true
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        if action == #selector(paste(_:)) && !canPaste {
            return false
        }
        if action == #selector(copy(_:)) && !canCopy {
            return false
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    override var canBecomeFirstResponder: Bool {
        true
    }
    
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

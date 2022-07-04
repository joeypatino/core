import UIKit

public protocol InputTextViewDelegate: AnyObject {
    func textViewDidBeginEditing(_ textView: InputTextView)
    func textViewDidChange(_ textView: InputTextView)
    func textViewDidEndEditing(_ textView: InputTextView)
}

extension InputTextViewDelegate {
    public func textViewDidBeginEditing(_ textView: InputTextView) {}
    public func textViewDidChange(_ textView: InputTextView) {}
    public func textViewDidEndEditing(_ textView: InputTextView) {}
}

public final class InputTextView: UIView {
    public enum FocusStyle {
        case unfocused
        case focused
    }

    public weak var delegate: InputTextViewDelegate?
    
    public var text: String {
        get { unsecureText }
        set { textView.text = newValue }
    }
    public var font: UIFont {
        get { textView.font ?? .systemFont(ofSize: 14.0, weight: .semibold) }
        set { textView.font = newValue }
    }
    public var textColor: UIColor {
        get { textView.textColor ?? UIColor.white }
        set { textView.textColor = newValue }
    }
    public var placeholder: String {
        get { textView.placeholder }
        set { textView.placeholder = newValue; updatePlaceholder() }
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

    public var isSecureTextEntry: Bool {
        get { textView.isSecureTextEntry }
        set {
            textView.isSecureTextEntry = newValue
            updateSecureText()
        }
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
    
    private var unsecureText = ""
    private let textView = TextView()
    private let header: UILabel
    private let stack = UIStackView(axis: .horizontal)
    
    private var stackHeightConstraint = NSLayoutConstraint()
    private var minHeightConstraint = NSLayoutConstraint()
    private var headerLeadingConstraint = NSLayoutConstraint()
    private var headerTopHeightConstraint = NSLayoutConstraint()
    private var headerCenterYConstraint = NSLayoutConstraint()
    private var textTopConstraint = NSLayoutConstraint()

    public var minimumHeight: CGFloat = 64 {
        didSet { updateHeight() }
    }
    public var displaysHeader: Bool = true {
        didSet { textTopConstraint.isActive = !displaysHeader }
    }
    public var headerColor: UIColor = .lightGray {
        didSet { updateHeader() }
    }
    public var headerFont: UIFont {
        headerStyle == .focused ? focusedHeaderFont : unFocusedHeaderFont
    }
    public var focusedBorderColor: UIColor = .white {
        didSet { updateBorder() }
    }
    public var unFocusedBorderColor: UIColor = .darkGray {
        didSet { updateBorder() }
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
    private var focusedHeaderOffset: CGPoint = .init(x: 16, y: 12)
    private var unFocusedHeaderOffset: CGPoint = .init(x: 16, y: 20)
    private var borderWidth: CGFloat {
        borderStyle == .focused ? focusedBorderWidth : unFocusedBorderWidth
    }
    private var headerOffset: CGPoint {
        headerStyle == .focused ? focusedHeaderOffset : unFocusedHeaderOffset
    }
    private var borderStyle: FocusStyle = .unfocused {
        didSet { updateBorder() }
    }
    private var headerStyle: FocusStyle = .unfocused {
        didSet { updateHeader() }
    }
    
    public init(headerLabel: UILabel = UILabel(), header: String? = nil, placeholder: String? = nil, defaultValue: String? = nil) {
        self.header = headerLabel
        self.header.text = header
        self.textView.text = defaultValue
        super.init(frame: .zero)
        self.placeholder = placeholder.orEmpty
        setup()
        layout()
        updateFocusStyle()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func updateConstraints() {
        super.updateConstraints()
        removeConstraint(minHeightConstraint)
        minHeightConstraint = heightAnchor.greaterThanOrEqualToConstant(minimumHeight)
    }

    public override var canBecomeFirstResponder: Bool {
        textView.canBecomeFirstResponder
    }
    
    public override func becomeFirstResponder() -> Bool {
        textView.becomeFirstResponder()
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        textView.becomeFirstResponder()
    }
    
    private func updateFocusStyle() {
        borderStyle = .unfocused
        headerStyle = textView.text.orEmpty.isEmpty ? .unfocused : .focused
    }
    
    private func setup() {
        stack.alignment = .center
        stack.spacing = 14
        stack.addArrangedSubview(Spacer(orientation: .horizonal(width: 0)))
        textView.layoutManager.delegate = self
        textView.textContainer.lineFragmentPadding = 0
        textView.textContainerInset = .zero
        textView.contentInset = .zero
        textView.isScrollEnabled = false
        textView.backgroundColor = .clear
        textView.textColor = .white
        textView.font = .systemFont(ofSize: 14.0, weight: .semibold)
        textView.delegate = self
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
        headerCenterYConstraint = header.centerYAnchor.equalTo(topAnchor).constant(32)
        headerCenterYConstraint.isActive = false

        addAutoLayoutSubview(textView)
        textTopConstraint = textView.topAnchor.equalTo(topAnchor).constant(16)
        textView.leadingAnchor.equalTo(header.leadingAnchor)
        textView.trailingAnchor.equalTo(stack.leadingAnchor).constant(-12)
        textView.bottomAnchor.equalTo(bottomAnchor).constant(-12)
        
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
            headerTopHeightConstraint.isActive = true
            headerCenterYConstraint.isActive = false
        }
    }
    
    private func updateHeight() {
        stackHeightConstraint.constant = minimumHeight
        minHeightConstraint.constant = minimumHeight
    }
    
    public func setText(_ text: String) {
        self.unsecureText = text
        self.text = unsecureText.masked
        self.headerStyle = textView.text.orEmpty.isEmpty ? .unfocused : .focused
        self.delegate?.textViewDidChange(self)
    }
    
    public func addAccessoryView(_ view: UIView) {
        stack.addArrangedSubview(view)
    }
    
    private func updateSecureText() {
        let existingSelectedTextRange = textView.selectedTextRange
        if isSecureTextEntry {
            textView.text = unsecureText.masked
        } else {
            textView.text = unsecureText
        }
        textView.selectedTextRange = existingSelectedTextRange
    }
    
    private func updatePlaceholder() {
        let attrs: [NSAttributedString.Key: Any] = [.font: placeholderFont ?? font,
                                                    .foregroundColor: placeholderColor,
                                                    .kern: placeholderKern]
        textView.placeholderLabel.attributedText = NSAttributedString(string: (placeholder), attributes: attrs)
    }
}

extension InputTextView: UITextViewDelegate {
    public func textViewDidBeginEditing(_ textView: UITextView) {
        delegate?.textViewDidBeginEditing(self)
        self.borderStyle = .focused
        self.headerStyle = .focused
        let animations = { self.layoutIfNeeded() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }
    public func textViewDidEndEditing(_ textView: UITextView) {
        delegate?.textViewDidEndEditing(self)
        self.borderStyle = .unfocused
        self.headerStyle = textView.text.orEmpty.isEmpty ? .unfocused : .focused
        let animations = { self.layoutIfNeeded() }
        UIView.animate(withDuration: 0.35, delay: 0, options: [], animations: animations)
    }
    public func textViewDidChange(_ textView: UITextView) {
        if isSecureTextEntry { textView.text = unsecureText.masked }
        delegate?.textViewDidChange(self)
    }
    public func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard text == "\n" else {
            unsecureText = (unsecureText as NSString).replacingCharacters(in: range, with: text)
            return true
        }
        textView.resignFirstResponder()
        return false
    }
}

extension InputTextView: NSLayoutManagerDelegate {
    public func layoutManager(_ layoutManager: NSLayoutManager, lineSpacingAfterGlyphAt glyphIndex: Int, withProposedLineFragmentRect rect: CGRect) -> CGFloat {
        6
    }
}

extension String {
    var masked: String {
        String(repeating: "*", count: count)
    }
}


//    public var focusedBorderColor: UIColor {
//        get { textField.focusedBorderColor }
//        set { textField.focusedBorderColor = newValue }
//    }
//    public var focusedHeaderFont: UIFont {
//        get { textField.focusedHeaderFont }
//        set { textField.focusedHeaderFont = newValue }
//    }
//    public var focusedBorderWidth: CGFloat {
//        get { textField.focusedBorderWidth }
//        set { textField.focusedBorderWidth = newValue }
//    }
//
//    public var unFocusedBorderColor: UIColor {
//        get { textField.unFocusedBorderColor }
//        set { textField.unFocusedBorderColor = newValue }
//    }
//    public var unFocusedHeaderFont: UIFont {
//        get { textField.unFocusedHeaderFont }
//        set { textField.unFocusedHeaderFont = newValue }
//    }
//    public var unFocusedBorderWidth: CGFloat {
//        get { textField.unFocusedBorderWidth }
//        set { textField.unFocusedBorderWidth = newValue }
//    }

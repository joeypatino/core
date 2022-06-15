import UIKit
import Combine

public protocol SecureTextEntry {
    var isSecureTextEntry: Bool { get set }
}

public class InputField: UIView {
    @Published public var text: String = ""
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
    
    internal let textField: InputTextField
    private let footer = UILabel(font: .systemFont(ofSize: 12.0, weight: .regular), color: .lightGray)
    
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
    
    required init?(coder: NSCoder) {
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
}

extension InputField: InputTextFieldDelegate {
    func textFieldDidChange(_ textField: InputTextField) {
        text = textField.text
    }
    func textFieldDidEndEditing(_ textField: InputTextField) {
        text = textField.text
    }
}


public class PasswordInputField: InputField {
    public override var placeholderColor: UIColor {
        get { textField.placeholderColor }
        set { textField.placeholderColor = newValue; togglePassword.tintColor = newValue }
    }
    private let togglePassword = TogglePasswordButton()
    
    public override init(headerLabel: UILabel = UILabel(),
                placeholder: String? = nil,
                headerText: String? = nil,
                footerText: String? = nil,
                defaultText: String? = nil) {
        super.init(headerLabel: headerLabel, placeholder: placeholder, headerText: headerText, footerText: footerText, defaultText: defaultText)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        togglePassword.addTarget(self, action: #selector(togglePasswordAction(_:)), for: .touchUpInside)
        togglePassword.tintColor = textField.placeholderColor
        textField.addAccessoryView(togglePassword)
    }
    
    private func layout() {
        
    }
    
    @objc private func togglePasswordAction(_ sender: UIButton) {
        togglePassword.isSelected = !togglePassword.isSelected
        textField.isSecureTextEntry = togglePassword.isSelected
    }
}

extension PasswordInputField: SecureTextEntry {
    public var isSecureTextEntry: Bool {
        get { textField.isSecureTextEntry }
        set { textField.isSecureTextEntry = newValue }
    }
}

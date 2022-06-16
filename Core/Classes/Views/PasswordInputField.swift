import UIKit

public protocol SecureTextEntry {
    var isSecureTextEntry: Bool { get set }
}

public final class PasswordInputField: InputField {
    public override var placeholderColor: UIColor {
        didSet { togglePassword.tintColor = placeholderColor }
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
        // start with input in secure entry mode
        textField.isSecureTextEntry = true
        togglePassword.isSelected = true
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

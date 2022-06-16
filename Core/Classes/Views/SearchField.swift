import UIKit
import Combine

open class SearchField: UIView {
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
        set { textField.unFocusedBorderColor = newValue; leftView?.tintColor = newValue; clear.tintColor = newValue }
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
        set { textField.borderRadius = newValue; layer.cornerRadius = newValue }
    }
    public var displaysHeader: Bool {
        get { textField.displaysHeader }
        set { textField.displaysHeader = newValue }
    }
    
    public var minimumHeight: CGFloat {
        get { textField.minimumHeight }
        set { textField.minimumHeight = newValue }
    }
    
    public var leftView: UIView? {
        get { textField.leftView }
        set { textField.leftView = newValue; leftView?.tintColor = unFocusedBorderColor; clear.tintColor = unFocusedBorderColor }
    }
    
    public var leftViewMode: UITextField.ViewMode {
        get { textField.leftViewMode }
        set { textField.leftViewMode = newValue }
    }

    public var absoluteTextInsets: UIEdgeInsets {
        get { textField.absoluteTextInsets }
        set { textField.absoluteTextInsets = newValue }
    }

    private let textField: InputTextField
    private let clear = ClearButton()
    
    public init(defaultValue: String? = nil) {
        self.textField = InputTextField(defaultValue: defaultValue)
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        clear.addTarget(self, action: #selector(onClearAction(_:)), for: .touchUpInside)
        
        layer.cornerRadius = borderRadius
        textField.displaysHeader = false
        textField.insets.left = 0
        textField.delegate = self
        textField.autocorrectionType = .no
        textField.autocapitalizationType = .none
        textField.leftViewMode = .always
        textField.clearButtonMode = .whenContentAvailable
        textField.addAccessoryView(clear)
        leftView = UIImageView(image: UIImage(systemName: "magnifyingglass"))
        absoluteTextInsets.left = 8
    }
    
    private func layout() {
        textField.embed(in: self)
    }
    
    @objc private func onClearAction(_ sender: UIButton) {
        textField.setText("")
    }
}

extension SearchField: InputTextFieldDelegate {
    public func textFieldDidChange(_ textField: InputTextField) {
        text = textField.text
    }
    
    public func textFieldDidBeginEditing(_ textField: InputTextField) {
        text = textField.text
    }
}

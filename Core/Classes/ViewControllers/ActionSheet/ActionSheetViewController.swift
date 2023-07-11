import UIKit

public struct ActionSheetAction {
    public var title: String?
    public var icon: UIImage?
    public let action: (() -> Void)?
    public var titleAttributes: [NSAttributedString.Key: Any]? = nil

    public init(title: String?, icon: UIImage? = nil, titleAttributes: [NSAttributedString.Key: Any]? = nil, action: (() -> Void)? = nil) {
        self.title = title
        self.icon = icon
        self.titleAttributes = titleAttributes
        self.action = action
    }
}

public protocol ActionSheetViewControllerDelegate: AnyObject {
    func viewControllerDone(_ viewController: ActionSheetViewController)
    func viewControllerDone(_ viewController: ActionSheetViewController, onCompletion completion: @escaping () -> Void)
    func viewControllerDidCancel(_ viewController: ActionSheetViewController)
}

public extension ActionSheetViewControllerDelegate {
    func viewControllerDone(_ viewController: ActionSheetViewController, onCompletion completion: @escaping () -> Void) {
        viewControllerDone(viewController)
        completion()
    }
}

public final class ActionSheetViewController: UIViewController {
    public static let defaultTitleAttributes: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.systemFont(ofSize: 16.0, weight: .regular) as Any, .foregroundColor: UIColor.black]
    public var delegate: ActionSheetViewControllerDelegate?
    public var titleAttributes: [NSAttributedString.Key: Any] = ActionSheetViewController.defaultTitleAttributes {
        didSet { stylize() }
    }
    
    private lazy var cancel = UIButton()
    private var actions: [ActionSheetAction] = []
    private var buttons: [ActionSheetButton] = []
    
    /// when true, the delegate is called when the view is touched outside bounds of any of the buttons
    public var cancelsOnOutsideTouches: Bool = true

    public init() {
        super.init(nibName: nil, bundle: nil)
        modalPresentationStyle = .overFullScreen
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = UIView(backgroundColor: .clear)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        configure()
        stylize()
    }

    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard cancelsOnOutsideTouches else { return }
        delegate?.viewControllerDidCancel(self)
    }

    // MARK: Setup
    
    private func actionSheetButton(at index: Int) -> ActionSheetButton {
        let button = ActionSheetButton()
        let action = actions[index]
        button.image = action.icon
        var attributes = titleAttributes
        for (_, attr) in (action.titleAttributes ?? [:]).enumerated() {
            attributes[attr.key] = attr.value
        }
        button.setAttributedTitle(NSAttributedString(string: action.title ?? "", attributes: attributes), for: .normal)
        button.addTarget(self, action: #selector(onAction), for: .touchUpInside)
        button.tag = index

        switch index {
        case 0 where actions.count == 1:
            // round the top-left and top-right corners of the top button
            button.layer.cornerRadius = 8
            button.maskedCorners = .allCorners
        case 0 where actions.count > 1:
            // round the top-left and top-right corners of the top button
            button.layer.cornerRadius = 8
            button.maskedCorners = [.topLeftCorner, .topRightCorner]
        case actions.count - 1:
            // round the bottom-left and bottom-right corners of the bottom button
            button.layer.cornerRadius = 8
            button.maskedCorners = [.bottomLeftCorner, .bottomRightCorner]
        default: break
        }

        return button
    }
    
    private func layout() {
        additionalSafeAreaInsets = UIEdgeInsets(top: 0, left: 20, bottom: 20, right: 20)
        
        var topAnchor = view.safeAreaLayoutGuide.topAnchor
        for (idx, _) in actions.enumerated() {
            
            // setup each of the buttons...
            let button = actionSheetButton(at: idx)
            view.addAutoLayoutSubview(button)
            _ = (idx == 0)
                ? button.topAnchor.greaterThanOrEqualTo(topAnchor)
                : button.topAnchor.equalTo(topAnchor)
            button.leadingAnchor.equalTo(view.safeAreaLayoutGuide.leadingAnchor)
            button.trailingAnchor.equalTo(view.safeAreaLayoutGuide.trailingAnchor)
            button.heightAnchor.equalToConstant(56)
            topAnchor = button.bottomAnchor

            // add the separator line where needed...
            if idx < actions.count - 1 {
                let line_one = UIView(backgroundColor: UIColor(red:0.59, green:0.59, blue:0.59, alpha:0.2))
                view.addAutoLayoutSubview(line_one)
                line_one.heightAnchor.equalToConstant(1)
                line_one.leadingAnchor.equalTo(button.leadingAnchor)
                line_one.trailingAnchor.equalTo(button.trailingAnchor)
                line_one.bottomAnchor.equalTo(button.bottomAnchor)
            }
            buttons.append(button)
        }

        // setup the cancel button
        view.addAutoLayoutSubview(cancel)
        if let last = buttons.last { cancel.topAnchor.equalTo(last.bottomAnchor).constant(16) }
        cancel.leadingAnchor.equalTo(view.safeAreaLayoutGuide.leadingAnchor)
        cancel.trailingAnchor.equalTo(view.safeAreaLayoutGuide.trailingAnchor)
        cancel.bottomAnchor.equalTo(view.safeAreaLayoutGuide.bottomAnchor)
        cancel.heightAnchor.equalToConstant(56)

        preferredContentSize = CGSize(width: view.bounds.width, height: view.requiredHeight + UIApplication.shared.windowSafeAreaInsets.bottom + additionalSafeAreaInsets.bottom)
    }
    
    private func configure() {
        cancel.backgroundColor = .white
        cancel.contentHorizontalAlignment = .center
        
        cancel.layer.cornerRadius = 8
        cancel.maskedCorners = .allCorners
        cancel.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
    }
    
    private func stylize() {
        cancel.setAttributedTitle(NSAttributedString(string: Localization.ActionSheet.cancel.localizedString, attributes: titleAttributes), for: .normal)
    }
    
    // MARK: Public
    
    public func addAction(_ action: ActionSheetAction) {
        actions.append(action)
    }
    
    // MARK: Actions
    
    @objc private func cancelAction(_ sender: UIButton) {
        delegate?.viewControllerDidCancel(self)
    }
    
    @objc private func onAction(_ sender: UIButton) {
        delegate?.viewControllerDone(self) {
            let tag = sender.tag
            let action = self.actions[tag]
            action.action?()
        }
    }
}

fileprivate final class ActionSheetButton: UIView {
    private lazy var button = UIButton(type: .custom)
    private lazy var icon = UIImageView()
    private lazy var label = UILabel()
    private var labelLeading = NSLayoutConstraint()
    private var labelTrailing = NSLayoutConstraint()
    
    override var tag: Int {
        didSet { button.tag = tag }
    }

    public var image: UIImage? {
        didSet {
            icon.image = image
            labelLeading.isActive = image != nil
            labelTrailing.isActive = image != nil
        }
    }
    
    public init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .white
        icon.contentMode = .scaleAspectFit
        icon.tintColor = .black
    }
    
    private func layout() {
        addAutoLayoutSubview(icon)
        icon.leadingAnchor.equalTo(leadingAnchor).constant(16)
        icon.centerYAnchor.equalTo(centerYAnchor)
        icon.widthAnchor.equalToConstant(22)
        icon.heightAnchor.equalToConstant(22)
        
        addAutoLayoutSubview(label)
        label.centerYAnchor.equalTo(centerYAnchor)
        labelLeading = label.leadingAnchor.equalTo(leadingAnchor).constant(55)
        label.centerXAnchor.equalTo(centerXAnchor, priority: 999)
        labelTrailing = label.trailingAnchor.equalTo(trailingAnchor).constant(-55)
        
        button.embed(in: self)
    }
    
    public func addTarget(_ target: Any?, action: Selector, for controlEvents: UIControl.Event) {
        button.addTarget(target, action: action, for: controlEvents)
    }
    
    public func setAttributedTitle(_ title: NSAttributedString?, for state: UIControl.State) {
        guard let text = title?.string else { label.text = nil; return }
        let attrs = title?.attributes(at: 0, effectiveRange: nil) ?? [:]
        if let font = attrs[.font] as? UIFont {
            label.font = font
        }
        if let color = attrs[.foregroundColor] as? UIColor {
            label.textColor = color
        }
        if let style = attrs[.paragraphStyle] as? NSParagraphStyle {
            label.textAlignment = style.alignment
            label.lineBreakMode = style.lineBreakMode
        }
        label.text = text
    }
}

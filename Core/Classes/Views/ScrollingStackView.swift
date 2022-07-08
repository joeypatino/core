import UIKit

public protocol StackView {
    var axis: NSLayoutConstraint.Axis { get }
    func addArrangedSubview(_ view: UIView)
}

extension ScrollingStackView: StackView {}
extension UIStackView: StackView {}

open class ScrollingStackView: UIScrollView {
    // MARK: - Properties
    public let stackView = UIStackView()
    
    public var axis: NSLayoutConstraint.Axis {
        get { stackView.axis }
        set {
            stackView.axis = newValue
            stackViewWidthConstraint.isActive = newValue == .vertical
            stackViewHeightConstraint.isActive = newValue == .horizontal
        }
    }
    public var distribution: UIStackView.Distribution {
        get { stackView.distribution }
        set { stackView.distribution = newValue }
    }
    public var alignment: UIStackView.Alignment {
        get { stackView.alignment }
        set { stackView.alignment = newValue }
    }
    public var spacing: CGFloat {
        get { stackView.spacing }
        set { stackView.spacing = newValue }
    }
    public var stackContentInsets: UIEdgeInsets = .zero {
        didSet {
            contentInset = stackContentInsets
            stackViewWidthConstraint.constant = -stackContentInsets.horizontalLength
            stackViewHeightConstraint.constant = -stackContentInsets.verticalLength
            stackView.layoutIfNeeded()
        }
    }
    public var isLayoutMarginsRelativeArrangement: Bool {
        get { stackView.isLayoutMarginsRelativeArrangement }
        set { stackView.isLayoutMarginsRelativeArrangement = newValue }
    }
    public var arrangedSubviews: [UIView] {
        stackView.arrangedSubviews
    }
    private lazy var stackViewWidthConstraint = stackView.widthAnchor.constraint(equalTo: widthAnchor)
    private lazy var stackViewHeightConstraint = stackView.heightAnchor.constraint(equalTo: heightAnchor)

    // MARK: - Lifecycle
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    public convenience init(axis: NSLayoutConstraint.Axis, subviews: [UIView] = [], distribution: UIStackView.Distribution = .fill, alignment: UIStackView.Alignment = .fill) {
        self.init(frame: .zero)
        self.axis = axis
        self.distribution = distribution
        self.alignment = alignment
        subviews.forEach { stackView.addArrangedSubview($0) }
    }
    
    // MARK: - Tasks
    private func commonInit() {
        setupStackView()
    }

    private func setupStackView() {
        stackView.embed(in: self)
        stackView.distribution = .equalSpacing
        sendSubviewToBack(stackView)
        axis = .vertical
    }

    public func addArrangedSubview(_ view: UIView) {
        stackView.addArrangedSubview(view)
    }
    
    public func removeAllArrangedSubviews() {
        for view in stackView.arrangedSubviews {
            view.removeFromSuperview()
        }
    }
    
    public func setCustomSpacing(_ spacing: CGFloat, after arrangedSubview: UIView) {
        stackView.setCustomSpacing(spacing, after: arrangedSubview)
    }

    public func customSpacing(after arrangedSubview: UIView) -> CGFloat {
        stackView.customSpacing(after: arrangedSubview)
    }
}

public extension StackView {
    func addArrangedSubview(_ view: UIView, alignment: UIStackView.Alignment) {
        let leading = CGFloat(0)
        let trailing = CGFloat(0)

        let stack = UIStackView()
        switch axis {
        case .horizontal:
            stack.axis = .horizontal
            stack.alignment = alignment
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: leading), huggingPriority: 249))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: trailing), huggingPriority: 249))
        case .vertical:
            stack.axis = .vertical
            stack.alignment = alignment
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: leading), huggingPriority: 249))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: trailing), huggingPriority: 249))
        @unknown default:
            break
        }
        addArrangedSubview(stack)
    }
    
    func addArrangedSubview(_ view: UIView, leadingMargin leading: CGFloat = 0, trailingMargin trailing: CGFloat = 0) {        
        let stack = UIStackView()
        switch axis {
        case .horizontal:
            stack.axis = .vertical
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: leading)))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(Spacer(orientation: .vertical(height: trailing)))
        case .vertical:
            stack.axis = .horizontal
            stack.addArrangedSubview(Spacer(orientation: .horizonal(width: leading)))
            stack.addArrangedSubview(view)
            stack.addArrangedSubview(Spacer(orientation: .horizonal(width: trailing)))
        @unknown default:
            break
        }
        addArrangedSubview(stack)
    }
}

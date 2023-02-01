import UIKit

public class ActivityButton: UIButton {
    private var text: String?
    private var activity = UIActivityIndicatorView()
    public var isActive: Bool = false {
        didSet { isActive ? showLoading() : hideLoading() }
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
        activity.hidesWhenStopped = true
        activity.color = .lightGray
    }
    
    private func layout() {
        
    }
    
    private func showLoading() {
        text = titleLabel?.text
        setTitle("", for: .normal)
        showSpinning()
    }
    
    private func hideLoading() {
        setTitle(text, for: .normal)
        activity.stopAnimating()
    }
    
    private func showSpinning() {
        guard !activity.isAnimating else { return }
        activity.center(in: self)
        activity.startAnimating()
    }
}

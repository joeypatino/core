import UIKit
import Core

class PageIndicatorViewController: UIViewController {
    private let indicator = PageIndicatorView()
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        indicator.numberOfSteps = 5
    }
    
    private func layout() {
        view.addAutoLayoutSubview(indicator)
        indicator.bottomAnchor.equalTo(view.safeAreaLayoutGuide.bottomAnchor).constant(-40)
        indicator.centerXAnchor.equalTo(view.centerXAnchor)
    }
}

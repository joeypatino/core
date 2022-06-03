import UIKit
import Core

class ActionSheetPlaygroundViewController: UIViewController {
    var actionSheet: ActionSheetTransitioningDelegate?
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
        
    }
    
    private func layout() {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Open...", for: .normal)
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.heightAnchor.equalToConstant(60)
        button.centerXAnchor.equalTo(view.centerXAnchor)
        button.centerYAnchor.equalTo(view.centerYAnchor)
        button.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        actionSheet = ActionSheetTransitioningDelegate(presentingViewController: self)
        let viewController = ActionSheetViewController()
        let action = ActionSheetAction(title: "Hello!", icon: nil)
        viewController.addAction(action)
        viewController.delegate = self
        viewController.transitioningDelegate = actionSheet
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }
}

extension ActionSheetPlaygroundViewController: ActionSheetViewControllerDelegate {
    public func viewControllerDone(_ viewController: ActionSheetViewController, onCompletion completion: @escaping () -> Void) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
                completion()
            }
        } else {
            dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
                completion()
            }
        }
    }
    
    public func viewControllerDone(_ viewController: ActionSheetViewController) {
        viewControllerDone(viewController, onCompletion: {})
    }
    
    public func viewControllerDidCancel(_ viewController: ActionSheetViewController) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
            }
        } else {
            dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
            }
        }
    }
}

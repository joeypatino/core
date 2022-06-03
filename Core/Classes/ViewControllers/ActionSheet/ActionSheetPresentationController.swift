import UIKit

public final class ActionSheetPresentationController: UIPresentationController, KeyboardObserver {
    public lazy var backgroundView: UIView = {
        let view = UIView(backgroundColor: backgroundViewColor)
        view.frame = CGRect(origin: .zero, size: containerView?.bounds.size ?? .zero)
        if allowsDismissOnTap {
            view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dissmissAction)))
        }
        return view
    }()
    private let allowsDismissOnTap: Bool
    private let backgroundViewColor: UIColor
    private var keyboardFrame: CGRect = .zero

    override public var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }
        let preferredContentHeight: CGFloat
        preferredContentHeight = min(presentedViewController.preferredContentSize.height, containerBounds.height - keyboardFrame.height - 20)
        return CGRect(x: 0,
                      y: containerBounds.height - preferredContentHeight,
                      width: containerBounds.width,
                      height: preferredContentHeight)
            .offsetBy(dx: 0, dy: -keyboardFrame.height)
    }
    
    public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, backgroundViewColor: UIColor, allowsDismissOnTap: Bool) {
        self.backgroundViewColor = backgroundViewColor
        self.allowsDismissOnTap = allowsDismissOnTap
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowNotification), name: UIApplication.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideNotification), name: UIApplication.keyboardWillHideNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    public func layoutPresentedViewController() {
        presentedViewController.view?.frame = frameOfPresentedViewInContainerView
    }
    
    override public func presentationTransitionWillBegin() {
        super.presentationTransitionWillBegin()
        backgroundView.alpha = 0
        containerView?.addSubview(backgroundView)
        backgroundView.addSubview(presentedViewController.view)
        presentingViewController
            .transitionCoordinator?
            .animate(alongsideTransition: { [weak self] context in
                self?.backgroundView.alpha = 1
            })
    }

    override public func dismissalTransitionWillBegin() {
        super.dismissalTransitionWillBegin()
        presentingViewController
            .transitionCoordinator?
            .animate(alongsideTransition: { [weak self] context in
                self?.backgroundView.alpha = 0
            })
    }
    
    override public func dismissalTransitionDidEnd(_ completed: Bool) {
        super.dismissalTransitionDidEnd(completed)
        guard completed else { return }
        backgroundView.removeFromSuperview()
    }
    
    // MARK: Actions
    
    @objc private func dissmissAction(_ gesture: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }

    @objc private func keyboardWillShowNotification(_ notification: Notification) {
        dispatch(keyboardNotification: notification) { frame, duration, options in
            self.keyboardFrame = frame
            let animations:() -> Void = { self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView }
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations)
        }
    }
    
    @objc private func keyboardWillHideNotification(_ notification: Notification) {
        dispatch(keyboardNotification: notification) { _, duration, options in
            self.keyboardFrame = .zero
            let animations:() -> Void = { self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView }
            UIView.animate(withDuration: duration, delay: 0, options: options, animations: animations)
        }
    }
}

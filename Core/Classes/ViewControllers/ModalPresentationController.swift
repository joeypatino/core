import UIKit

public extension UIViewController {
    func presentModal<T>(_ presentationController: T, completion: (() -> Void)? = nil) where T: ModalPresentationController {
        let viewController = presentationController.presentedViewController
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: completion)
    }
    
    @discardableResult
    func presentModal<T>(_ viewController: UIViewController, canTapToDismiss: Bool = true, canSwipeDownToDismiss: Bool = true, completion: (() -> Void)? = nil) -> T where T: ModalPresentationController {
        let presentationController = T.init(presentedViewController: viewController,
                                            presenting: self,
                                            canTapToDismiss: canTapToDismiss,
                                            canSwipeDownToDismiss: canSwipeDownToDismiss)
        viewController.transitioningDelegate = presentationController
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true, completion: completion)
        return presentationController
    }
}

open class ModalPresentationController: UIPresentationController {
    public let background = UIView()
    public var canTapToDismiss: Bool
    public var canSwipeDownToDismiss: Bool
    private let interactor = UIPercentDrivenInteractiveTransition()
    private var propertyAnimator: UIViewPropertyAnimator!
    private var isInteractive = false
    private var scrollView: UIScrollView? {
        presentedView as? UIScrollView ?? presentedView?.firstSubview(of: UIScrollView.self)
    }
    private var presentedCornerRadius: CGFloat
    private var presentingCornerRadius: CGFloat
    private var presented: UIViewController? {
        func lastViewController(_ viewController: UIViewController) -> UIViewController {
            if let navigationController = viewController as? UINavigationController {
                if let top = navigationController.topViewController {
                    return lastViewController(top)
                } else {
                    return navigationController
                }
            } else if let tabBarController = viewController as? UITabBarController {
                if let selected = tabBarController.selectedViewController {
                    return lastViewController(selected)
                } else {
                    return tabBarController
                }
            } else {
                return viewController
            }
        }
        return lastViewController(presentingViewController)
    }
    public var topSpacing: CGFloat {
        let h = presentedViewController.view.requiredHeight
        let safeArea = UIApplication.shared.windowSafeAreaInsets.top + 20
        let screenHeight = UIScreen.main.bounds.height
        return screenHeight - safeArea - h
    }
    
    // MARK: Public Properties
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }
        var frame = containerBounds
        frame.size.height = (containerBounds.height - topSpacing)
        frame.origin.y = containerBounds.height - frame.size.height
        
        return frame
    }
    
    // MARK: Initializers
    
    required public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, canTapToDismiss: Bool = true, canSwipeDownToDismiss: Bool = true) {
        self.canTapToDismiss = canTapToDismiss
        self.canSwipeDownToDismiss = canSwipeDownToDismiss
        self.presentedCornerRadius = presentedViewController.view.layer.cornerRadius
        self.presentingCornerRadius = presentingViewController?.view.layer.cornerRadius ?? 0
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)
    }
    
    // MARK: Public Functions
    public override func presentationTransitionWillBegin() {
        guard let containerBounds = containerView?.bounds, let presentedView = presentedView else { return }
        
        presentingCornerRadius = presentingViewController.view.layer.cornerRadius
        presentedCornerRadius = presented?.view.layer.cornerRadius ?? 0
        presented?.view.layer.masksToBounds = true
        // Configure the presented view.
        containerView?.addSubview(presentedView)
        presentedView.layoutIfNeeded()
        presentedView.frame = frameOfPresentedViewInContainerView
        presentedView.frame.origin.y = containerBounds.height
        presentedView.layer.masksToBounds = true
        presentedView.layer.cornerRadius = 20
        
        // Add a dimming view below the presented view controller.
        background.backgroundColor = .black
        background.frame = containerBounds
        background.alpha = 0
        containerView?.insertSubview(background, at: 0)
        
        // Add pan gesture recognizers for interactive dismissal.
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan(_:)))
        presentedView.addGestureRecognizer(panGesture)
        scrollView?.panGestureRecognizer.addTarget(self, action: #selector(handlePan(_:)))
        
        // Add tap recognizer for dismissal.
        if canTapToDismiss { background.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismiss))) }
        
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.presentingViewController.view.layer.transform = self.calculatePerspectiveTransform()
            self.presentingViewController.view.layer.cornerRadius = 20
            self.presented?.view.layer.cornerRadius = 20
            self.background.alpha = 0.5
        })
    }
    
    public override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { [unowned self] _ in
            self.presentingViewController.view.layer.transform = CATransform3DIdentity
            self.presentingViewController.view.layer.cornerRadius = self.presentingCornerRadius
            self.presented?.view.layer.cornerRadius = self.presentedCornerRadius
            self.background.alpha = 0
        })
    }
    
    public override func dismissalTransitionDidEnd(_ completed: Bool) {
        propertyAnimator = nil
    }
    
    public override func preferredContentSizeDidChange(forChildContentContainer container: UIContentContainer) {
        super.preferredContentSizeDidChange(forChildContentContainer: container)
        
        if propertyAnimator != nil && !propertyAnimator.isRunning {
            // Respond to height changes in the child view controller.
            let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UISpringTimingParameters(dampingRatio: 1.0))
            animator.addAnimations {
                self.presentedView?.frame = self.frameOfPresentedViewInContainerView
            }
            animator.startAnimation()
        }
    }
    
    public func updatePresentedLayout() {
        let animations:() -> Void = { self.presentedViewController.view.frame = self.frameOfPresentedViewInContainerView }
        UIView.animate(withDuration: 0.5, delay: 0, options: [.curveEaseInOut], animations: animations)
    }
    
    open func canDismiss() -> Bool {
        true
    }
    
    // MARK: Private Functions
    
    func calculatePerspectiveTransform() -> CATransform3D {
        let eyePosition:Float = 16.0;
        var contentTransform:CATransform3D = CATransform3DIdentity
        contentTransform.m34 = CGFloat(-1/eyePosition)
        contentTransform = CATransform3DTranslate(contentTransform, 0, 0, -2)
        return contentTransform
    }
    
    @objc private func dismiss() {
        guard canDismiss() else { return }
        presentedViewController.dismiss(animated: true)
    }
    
    @objc private func handlePan(_ gesture: UIPanGestureRecognizer) {
        guard canDismiss() else { return }
        guard let containerView = containerView else { return }
        
        limitScrollView(gesture)
        
        let percent = gesture.translation(in: containerView).y / containerView.bounds.height
        switch gesture.state {
        case .began:
            if !presentedViewController.isBeingDismissed && scrollView?.contentOffset.y ?? 0 <= 0 {
                isInteractive = true
                presentedViewController.dismiss(animated: true)
            }
        case .changed:
            if canSwipeDownToDismiss {
                interactor.update(percent)
            } else {
                interactor.update(abs(1.0 - pow(1.5, percent)))
            }
        case .cancelled:
            interactor.cancel()
            isInteractive = false
        case .ended:
            if canSwipeDownToDismiss {
                let velocity = gesture.velocity(in: nil).y
                interactor.completionSpeed = 0.9
                if percent > 0.3 || velocity > 1600 {
                    interactor.finish()
                } else {
                    interactor.cancel()
                }
                isInteractive = false
            } else {
                interactor.cancel()
                isInteractive = false
            }
        default:
            break
        }
    }
    
    private func limitScrollView(_ gesture: UIPanGestureRecognizer) {
        guard let scrollView = scrollView else { return }
        if interactor.percentComplete > 0 {
            // Don't let the scroll view scroll while dismissing.
            scrollView.contentOffset.y = -scrollView.adjustedContentInset.top
        }
    }
}

// MARK: UIViewControllerAnimatedTransitioning
extension ModalPresentationController: UIViewControllerAnimatedTransitioning {
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        0.6
    }
    
    public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        interruptibleAnimator(using: transitionContext).startAnimation()
    }
    
    public func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        propertyAnimator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                                  timingParameters: UISpringTimingParameters(dampingRatio: 1.0,
                                                                                             initialVelocity: CGVector(dx: 1, dy: 1)))
        propertyAnimator.addAnimations { [unowned self] in
            if self.presentedViewController.isBeingPresented {
                transitionContext.view(forKey: .to)?.frame = self.frameOfPresentedViewInContainerView
            } else {
                transitionContext.view(forKey: .from)?.frame.origin.y = transitionContext.containerView.frame.maxY
            }
        }
        propertyAnimator.addCompletion { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        return propertyAnimator
    }
}

// MARK: UIViewControllerTransitioningDelegate
extension ModalPresentationController: UIViewControllerTransitioningDelegate {
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        self
    }
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        self
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        isInteractive ? interactor : nil
    }
}

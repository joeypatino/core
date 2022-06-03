import UIKit

public final class ActionSheetTransitioningDelegate: NSObject, UIViewControllerTransitioningDelegate {
    public var interactiveDismiss = false {
        didSet { interactionController.enabled = interactiveDismiss }
    }

    private var interactionController: ActionSheetInteractiveTransition
    private var presentationController: ActionSheetPresentationController?
    private var presentationBackgroundColor: UIColor
    private var allowsDismissOnTap: Bool
    
    public init(presentingViewController: UIViewController, backgroundColor: UIColor = UIColor.black.withAlphaComponent(0.7), allowsDismissOnTap: Bool = true) {
        self.interactionController = ActionSheetInteractiveTransition(presentingViewController: presentingViewController)
        self.presentationBackgroundColor = backgroundColor
        self.allowsDismissOnTap = allowsDismissOnTap
        super.init()
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return ActionSheetTransitionAnimator(type: .dismiss)
    }
    
    public func presentationController(forPresented presented: UIViewController, presenting: UIViewController?, source: UIViewController) -> UIPresentationController? {
        presentationController = ActionSheetPresentationController(presentedViewController: presented, presenting: presenting, backgroundViewColor: presentationBackgroundColor, allowsDismissOnTap: allowsDismissOnTap)
        presentationController?.delegate = self
        return presentationController
    }
    
    public func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        guard interactionController.isInteractive && interactiveDismiss else { return nil }
        return interactionController
    }
}

extension ActionSheetTransitioningDelegate: UIAdaptivePresentationControllerDelegate {
    public func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .overCurrentContext
    }
    
    public func adaptivePresentationStyle(for controller: UIPresentationController, traitCollection: UITraitCollection) -> UIModalPresentationStyle {
        return .overCurrentContext
    }
    
    public func presentationController(_ controller: UIPresentationController, viewControllerForAdaptivePresentationStyle style: UIModalPresentationStyle) -> UIViewController? {
        return nil
    }
    
    public func presentationController(_ presentationController: UIPresentationController, willPresentWithAdaptiveStyle style: UIModalPresentationStyle, transitionCoordinator: UIViewControllerTransitionCoordinator?) {
    }
}

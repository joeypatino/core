import UIKit

public enum ActionSheetTransitionAnimatorType {
    case present
    case dismiss
}

public final class ActionSheetTransitionAnimator: NSObject, UIViewControllerAnimatedTransitioning {
    private let type: ActionSheetTransitionAnimatorType
    public init(type: ActionSheetTransitionAnimatorType) {
        self.type = type
    }
    
    public func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return type == .present ? 0.4 : 0.25
    }
    
    @objc public func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let _ = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.to),
            let from = transitionContext.viewController(forKey: UITransitionContextViewControllerKey.from)
            else { return }
        
        let duration = transitionDuration(using: transitionContext)
        UIView.animate(withDuration: duration, animations: { from.view.frame.origin.y = UIScreen.main.bounds.height }) { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
    }
}


import UIKit

public extension UIViewController {
    /// Assign as listener to notification.
    /// - Parameters:
    ///   - name: notification name.
    ///   - selector: selector to run with notified.
    func addNotificationObserver(name: Notification.Name, selector: Selector) {
        NotificationCenter.default.addObserver(self, selector: selector, name: name, object: nil)
    }
    
    /// Unassign as listener to notification.
    /// - Parameter name: notification name.
    func removeNotificationObserver(name: Notification.Name) {
        NotificationCenter.default.removeObserver(self, name: name, object: nil)
    }
    
    /// Unassign as listener from all notifications.
    func removeNotificationsObserver() {
        NotificationCenter.default.removeObserver(self)
    }
}

public extension UIViewController {
    /// adds a UIViewController as a childViewController.
    /// - Parameters:
    ///   - child: the view controller to add as a child.
    ///   - containerView: the containerView for the child viewController's root view.
    func addChildViewController(_ child: UIViewController, toContainerView containerView: UIView) {
        addChild(child)
        containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// adds a UIViewController as a childViewController.
    /// - Parameters:
    ///   - child: the view controller to add as a child.
    ///   - addSubview: a block where you should add the child as a subview to the parent
    func addChildViewController(_ child: UIViewController, addSubview: @escaping (UIView) -> Void) {
        addChild(child)
        addSubview(child.view)
        //containerView.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    /// removes a UIViewController from its parent.
    func removeViewAndControllerFromParentViewController() {
        guard parent != nil else { return }
        
        willMove(toParent: nil)
        removeFromParent()
        view.removeFromSuperview()
    }
}

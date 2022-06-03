import UIKit

public typealias KeyboardObserverClosure = (CGRect, TimeInterval, UIView.AnimationOptions) -> Void

public protocol KeyboardObserver: AnyObject {
    func dispatch(keyboardNotification notification: Notification, to closure: KeyboardObserverClosure)
}

public extension KeyboardObserver {
    func dispatch(keyboardNotification notification: Notification, to closure: KeyboardObserverClosure) {
        guard
            let userInfo = notification.userInfo,
            let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue,
            let duration = userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double,
            let curve = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? UInt else {
                return
        }
        
        closure(keyboardFrame.cgRectValue, duration, UIView.AnimationOptions(rawValue: curve))
    }
}

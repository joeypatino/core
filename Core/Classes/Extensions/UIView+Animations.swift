import UIKit

public extension UIView {
    enum ShakeIntensity {
        case low
        case medium
    }
    func shake(intensity: ShakeIntensity = .medium, duration: CFTimeInterval) {
        let values: [Double]
        switch intensity {
        case .low:
            values = [-2, 2, -2, 2, -1, 1, -0.5, 0.5, 0]
        case .medium:
            values = [-5, 5, -5, 5, -3, 3, -2, 2, 0]
        }
        let translation = CAKeyframeAnimation(keyPath: "transform.translation.x");
        translation.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.linear)
        translation.values = values
        
        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        rotation.values = values.map {
            (degrees: Double) -> Double in
            let radians: Double = (Double.pi * degrees) / 180.0
            return radians
        }
        
        let shakeGroup: CAAnimationGroup = CAAnimationGroup()
        shakeGroup.animations = [translation, rotation]
        shakeGroup.duration = duration
        self.layer.add(shakeGroup, forKey: "shakeIt")
    }
}

public extension UIView {
    func pulse(duration: TimeInterval, repeatCount: Float = .infinity) {
        let animation = CAKeyframeAnimation(keyPath: "transform.scale")
        animation.values = [1.0, 1.05, 1.0]
        animation.keyTimes = [0, 0.5, 1]
        animation.duration = duration
        animation.repeatCount = repeatCount
        layer.add(animation, forKey: "pulse")
    }
}

public extension UIView {
    func bounce(_ duration: TimeInterval = 0.4, bounceComplete: (() -> Void)? = nil) {
        let animate = {
            self.transform = CGAffineTransform(scaleX: 1.1, y: 1.1)
        }
        let completion: (Bool) -> Void = { _ in
            UIView.animate(withDuration: duration * 0.75,
                           delay: 0,
                           usingSpringWithDamping: 0.3,
                           initialSpringVelocity: 6.0,
                           options: .allowUserInteraction,
                           animations: { [weak self] in
                self?.transform = .identity
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
                    bounceComplete?()
                }
            })
        }
        UIView.animate(withDuration: duration * 0.25, animations: animate, completion: completion)
    }
}

public extension UIView {
    /// Fade in view.
    /// - Parameters:
    ///   - duration: animation duration in seconds, default is 1 second.
    ///   - completion: optional completion handler to run with animation finishes, default is nil.
    func fadeIn(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 1
        }, completion: completion)
    }

    /// Fade out view.
    /// - Parameters:
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes, default is nil.
    func fadeOut(duration: TimeInterval = 1.0, completion: ((Bool) -> Void)? = nil) {
        if isHidden {
            isHidden = false
        }
        UIView.animate(withDuration: duration, animations: {
            self.alpha = 0
        }, completion: completion)
    }
}

import UIKit

public extension UIView {
    typealias EmbedConstraints = (top: NSLayoutConstraint, left: NSLayoutConstraint, bottom: NSLayoutConstraint, right: NSLayoutConstraint)
    typealias CenterConstraints = (width: NSLayoutConstraint, height: NSLayoutConstraint, centerX: NSLayoutConstraint, centerY: NSLayoutConstraint)
    
    @discardableResult
    func embed(in view: UIView, inset: UIEdgeInsets = .zero, usingSafeAreaLayoutGuides: Bool = false) -> EmbedConstraints {
        view.addAutoLayoutSubview(self)
        if usingSafeAreaLayoutGuides {
            let top = topAnchor.equalTo(view.safeAreaLayoutGuide.topAnchor).constant(inset.top)
            let left = leadingAnchor.equalTo(view.safeAreaLayoutGuide.leadingAnchor).constant(inset.left)
            let bottom = bottomAnchor.equalTo(view.safeAreaLayoutGuide.bottomAnchor).constant(-inset.bottom)
            let right = trailingAnchor.equalTo(view.safeAreaLayoutGuide.trailingAnchor).constant(-inset.right)
            return (top: top, left: left, bottom: bottom, right: right)
        } else {
            let top = topAnchor.equalTo(view.topAnchor).constant(inset.top)
            let left = leadingAnchor.equalTo(view.leadingAnchor).constant(inset.left)
            let bottom = bottomAnchor.equalTo(view.bottomAnchor).constant(-inset.bottom)
            let right = trailingAnchor.equalTo(view.trailingAnchor).constant(-inset.right)
            return (top: top, left: left, bottom: bottom, right: right)
        }
    }
    
    @discardableResult
    func center(in view: UIView, inset: UIEdgeInsets = .zero, offset: CGPoint = .zero) -> CenterConstraints {
        view.addAutoLayoutSubview(self)
        let width = widthAnchor.equalTo(view.widthAnchor).constant(-(inset.left + inset.right))
        let height = heightAnchor.equalTo(view.heightAnchor).constant(-(inset.top + inset.bottom))
        let centerX = centerXAnchor.equalTo(view.centerXAnchor).constant(offset.x)
        let centerY = centerYAnchor.equalTo(view.centerYAnchor).constant(offset.y)
        return (width: width, height: height, centerX: centerX, centerY: centerY)
    }
}

public extension UIView {
    var horizontalHugging: Float {
        get { return contentHuggingPriority(for: .horizontal).rawValue }
        set { setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }
    
    var verticalHugging: Float {
        get { return contentHuggingPriority(for: .vertical).rawValue }
        set { setContentHuggingPriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }
    
    var horizontalCompression: Float {
        get { return contentCompressionResistancePriority(for: .horizontal).rawValue }
        set { setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .horizontal) }
    }
    
    var verticalCompression: Float {
        get { return contentCompressionResistancePriority(for: .vertical).rawValue }
        set { setContentCompressionResistancePriority(UILayoutPriority(rawValue: newValue), for: .vertical) }
    }
}

public extension UIView {
    var requiredHeight: CGFloat {
        return systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    func requiredWidth(fittingHeight height: CGFloat) -> CGFloat {
        return systemLayoutSizeFitting(CGSize(width: 0, height: height), withHorizontalFittingPriority: .fittingSizeLevel, verticalFittingPriority: .required).width
    }
    
    func requiredHeight(fittingWidth width: CGFloat) -> CGFloat {
        return systemLayoutSizeFitting(CGSize(width: width, height: 0), withHorizontalFittingPriority: .required, verticalFittingPriority: .fittingSizeLevel).height
    }
}

public extension UIView {
    var parentViewController: UIViewController? {
        weak var parentResponder: UIResponder? = self
        while parentResponder != nil {
            parentResponder = parentResponder!.next
            if let viewController = parentResponder as? UIViewController {
                return viewController
            }
        }
        return nil
    }
}

public extension UIView {
    func addAutoLayoutSubview(_ subview: UIView) {
        subview.translatesAutoresizingMaskIntoConstraints = false
        addSubview(subview)
    }
    
    func removeSubviews() {
        subviews.forEach { $0.removeFromSuperview() }
    }
    
    /// Search all superviews until a view with the condition is found.
    /// - Parameter predicate: predicate to evaluate on superviews.
    func ancestorView(where predicate: (UIView?) -> Bool) -> UIView? {
        if predicate(superview) {
            return superview
        }
        return superview?.ancestorView(where: predicate)
    }
    
    /// Search all superviews until a view with this class is found.
    /// - Parameter name: class of the view to search.
    func ancestorView<T: UIView>(withClass _: T.Type) -> T? {
        return ancestorView(where: { $0 is T }) as? T
    }
    
    /// view hierarchy rooted on the view it its called.
    /// - Parameter ofType: Class of the view to search.
    /// - Returns: All subviews with a specified type.

    /// Returns first subviews of a given type
    /// - Parameter type: Class of the view to search.
    /// - Returns: first subviews with a specified type.
    func firstSubview<T: UIView>(of type: T.Type) -> T? {
        allSubviews.first { $0 is T } as? T
    }
        
    /// Returns all the subviews of a given type recursively in the
    /// view hierarchy rooted on the view it its called.
    /// - Parameter ofType: Class of the view to search.
    /// - Returns: All subviews with a specified type.
    func subviews<T>(ofType _: T.Type) -> [T] {
        var views = [T]()
        for subview in subviews {
            if let view = subview as? T {
                views.append(view)
            } else if !subview.subviews.isEmpty {
                views.append(contentsOf: subview.subviews(ofType: T.self))
            }
        }
        return views
    }
    
    var allSubviews: [UIView] {
        subviews + subviews.flatMap { $0.allSubviews }
    }
}

public extension UIView {
    /// Angle units
    enum AngleUnit {
        case degrees
        case radians
    }
    
    /// Rotate view by angle on relative axis.
    /// - Parameters:
    ///   - angle: angle to rotate view by.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is true).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        byAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1.0,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, delay: 0, options: .curveLinear, animations: { () -> Void in
                self.transform = self.transform.rotated(by: angleWithType)
            }, completion: completion)
        }
    
    /// Rotate view to angle on fixed axis.
    /// - Parameters:
    ///   - angle: angle to rotate view to.
    ///   - type: type of the rotation angle.
    ///   - animated: set true to animate rotation (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func rotate(
        toAngle angle: CGFloat,
        ofType type: AngleUnit,
        animated: Bool = false,
        duration: TimeInterval = 1.0,
        completion: ((Bool) -> Void)? = nil) {
            let angleWithType = (type == .degrees) ? .pi * angle / 180.0 : angle
            let aDuration = animated ? duration : 0
            UIView.animate(withDuration: aDuration, animations: {
                self.transform = self.transform.concatenating(CGAffineTransform(rotationAngle: angleWithType))
            }, completion: completion)
        }
    
    /// Scale view by offset.
    /// - Parameters:
    ///   - offset: scale offset
    ///   - animated: set true to animate scaling (default is false).
    ///   - duration: animation duration in seconds (default is 1 second).
    ///   - completion: optional completion handler to run with animation finishes (default is nil).
    func scale(
        by offset: CGPoint,
        animated: Bool = false,
        duration: TimeInterval = 1.0,
        completion: ((Bool) -> Void)? = nil) {
            if animated {
                UIView.animate(withDuration: duration, delay: 0, options: .curveLinear, animations: { () -> Void in
                    self.transform = self.transform.scaledBy(x: offset.x, y: offset.y)
                }, completion: completion)
            } else {
                transform = transform.scaledBy(x: offset.x, y: offset.y)
                completion?(true)
            }
        }
}

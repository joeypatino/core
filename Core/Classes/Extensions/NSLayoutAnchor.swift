import UIKit

@objc public extension NSLayoutAnchor {
    @discardableResult
    func equalTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        return equalTo(anchor, priority: 1000)
    }
    
    @discardableResult
    func lessThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        return lessThanOrEqualTo(anchor, priority: 1000)
    }
    
    @discardableResult
    func greaterThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>) -> NSLayoutConstraint {
        return greaterThanOrEqualTo(anchor, priority: 1000)
    }
    
    @discardableResult
    func equalTo(_ anchor: NSLayoutAnchor<AnchorType>, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: anchor)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func lessThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: anchor)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func greaterThanOrEqualTo(_ anchor: NSLayoutAnchor<AnchorType>, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: anchor)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
}

@objc public extension NSLayoutDimension {
    @discardableResult
    func equalTo(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let constraint = self.constraint(equalTo: dimension, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func lessThanOrEqualTo(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualTo: dimension, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func greaterThanOrEqualTo(_ dimension: NSLayoutDimension, multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualTo: dimension, multiplier: multiplier)
        constraint.isActive = true
        return constraint
    }

    @discardableResult
    func equalToConstant(_ constant: CGFloat) -> NSLayoutConstraint {
        return equalToConstant(constant, priority: 1000)
    }
    
    @discardableResult
    func lessThanOrEqualToConstant(_ constant: CGFloat) -> NSLayoutConstraint {
        return lessThanOrEqualToConstant(constant, priority: 1000)
    }
    
    @discardableResult
    func greaterThanOrEqualToConstant(_ constant: CGFloat) -> NSLayoutConstraint {
        return greaterThanOrEqualToConstant(constant, priority: 1000)
    }
    
    @discardableResult
    func equalToConstant(_ constant: CGFloat, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(equalToConstant: constant)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func lessThanOrEqualToConstant(_ constant: CGFloat, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(lessThanOrEqualToConstant: constant)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
    
    @discardableResult
    func greaterThanOrEqualToConstant(_ constant: CGFloat, priority: Float) -> NSLayoutConstraint {
        let constraint = self.constraint(greaterThanOrEqualToConstant: constant)
        constraint.priority = UILayoutPriority(rawValue: priority)
        constraint.isActive = true
        return constraint
    }
}

@objc public extension NSLayoutConstraint {
    @discardableResult
    func priority(_ priority: Float) -> NSLayoutConstraint {
        self.priority = UILayoutPriority(rawValue: priority)
        return self
    }
    
    @discardableResult
    func constant(_ constant: CGFloat) -> NSLayoutConstraint {
        self.constant = constant
        return self
    }

    @discardableResult
    func multiplier(_ multiplier: CGFloat) -> NSLayoutConstraint {
        NSLayoutConstraint.deactivate([self])
        let newConstraint = NSLayoutConstraint(
            item: firstItem as Any,
            attribute: firstAttribute,
            relatedBy: relation,
            toItem: secondItem,
            attribute: secondAttribute,
            multiplier: multiplier,
            constant: constant)

        newConstraint.priority = priority
        newConstraint.shouldBeArchived = self.shouldBeArchived
        newConstraint.identifier = self.identifier

        NSLayoutConstraint.activate([newConstraint])
        return newConstraint
    }
}

import UIKit

public extension UIStackView {
    func safelyRemoveArrangedSubviews(filteredBy filter: (UIView) -> Bool) {
        // Remove all the arranged subviews and save them to an array
        let removedSubviews = arrangedSubviews.reduce([]) { (sum, next) -> [UIView] in
            if !filter(next) { return sum }
            removeArrangedSubview(next)
            return sum + [next]
        }
        
        // Deactive all constraints at once
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
    func safelyRemoveArrangedSubviews() {
        safelyRemoveArrangedSubviews(filteredBy: { _ in return true })
    }
}

public extension UIStackView {
    convenience init(_ views: [UIView] = [], axis: NSLayoutConstraint.Axis, alignment: UIStackView.Alignment = .fill, distribution: UIStackView.Distribution = .fill, spacing: CGFloat = 0) {
        self.init(arrangedSubviews: views)
        self.axis = axis
        self.spacing = spacing
        self.alignment = alignment
        self.distribution = distribution
    }
}

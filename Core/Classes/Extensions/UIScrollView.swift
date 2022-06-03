import UIKit

public extension UIScrollView {
    enum LayoutAxis {
        case horizontal
    }
    
    convenience init(subviews: [UIView], axis: LayoutAxis = .horizontal) {
        self.init(frame: .zero)
        
        let containerView = UIView()
        containerView.center(in: self)
        
        var previousView: UIView?
        for view in subviews {
            containerView.addAutoLayoutSubview(view)
            
            // if the first view
            if view == subviews.first { view.leadingAnchor.equalTo(containerView.leadingAnchor) }
            
            view.widthAnchor.equalTo(widthAnchor)
            view.bottomAnchor.equalTo(containerView.bottomAnchor)
            view.topAnchor.equalTo(containerView.topAnchor)
            
            previousView?.trailingAnchor.equalTo(view.leadingAnchor)
            
            // if the last view
            if view == subviews.last { view.trailingAnchor.equalTo(containerView.trailingAnchor) }
            
            previousView = view
        }
        contentSize = CGSize(width: CGFloat(subviews.count) * bounds.width, height: 0)
    }
}

public extension UIScrollView {
    func zoom(to zoomPoint: CGPoint, withScale scale: CGFloat, animated: Bool = true) {
        if scale == zoomScale {
            delegate?.scrollViewDidZoom?(self)
            return
        }
        let contentSize = CGSize(width: self.contentSize.width / scale, height: self.contentSize.height / scale)
        let zoomPoint = CGPoint(x: (zoomPoint.x / bounds.width) * contentSize.width, y: (zoomPoint.y / bounds.height) * contentSize.height)
        
        let zoomSize = CGSize(width: bounds.width / scale, height: bounds.height / scale)
        let zoomRect = CGRect(x: zoomPoint.x - zoomSize.width / 2.0, y: zoomPoint.y - zoomSize.height / 2.0, width: zoomSize.width, height: zoomSize.height)
        zoom(to: zoomRect, animated: animated)
    }
}

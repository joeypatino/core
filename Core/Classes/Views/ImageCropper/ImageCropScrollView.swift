import UIKit

public class ImageCropScrollView: UIScrollView {
    public let imageView = UIImageView()
    public var imageToDisplay: UIImage? = nil {
        didSet{
            zoomScale = 1.0
            minimumZoomScale = 1.0
            imageView.image = imageToDisplay
            imageView.frame.size = sizeForImageToDisplay()
            imageView.center = center
            contentSize = imageView.frame.size
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
            updateLayout()
        }
    }
    private var gridView = UIView(backgroundColor: .clear)
    public init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        scrollsToTop = false
        clipsToBounds = false
        showsVerticalScrollIndicator = false
        showsHorizontalScrollIndicator = false
        alwaysBounceHorizontal = true
        alwaysBounceVertical = true
        bouncesZoom = true
        decelerationRate = UIScrollView.DecelerationRate.fast
        delegate = self
        maximumZoomScale = 5.0
        
        gridView.frame = frame
        gridView.isHidden = true
        gridView.isUserInteractionEnabled = false
        addSubview(gridView)
    }
    
    private func layout() {
        addSubview(imageView)
        addSubview(gridView)
    }
    
    private func updateLayout() {
        imageView.center = center;
        var frame:CGRect = imageView.frame;
        if (frame.origin.x < 0) { frame.origin.x = 0 }
        if (frame.origin.y < 0) { frame.origin.y = 0 }
        imageView.frame = frame
    }
    
    private func zoom() {
        if (zoomScale <= 1.0) { setZoomScale(zoomScaleWithNoWhiteSpaces(), animated: true) }
        else { setZoomScale(minimumZoomScale, animated: true) }
        updateLayout()
    }
    
    private func sizeForImageToDisplay() -> CGSize {
        guard let imageToDisplay = imageToDisplay else { return .zero}
        var actualWidth = imageToDisplay.size.width
        var actualHeight = imageToDisplay.size.height
        var imgRatio = actualWidth / actualHeight
        let maxRatio = frame.size.width / frame.size.height
        
        if imgRatio != maxRatio {
            if (imgRatio < maxRatio) {
                imgRatio = frame.size.height / actualHeight
                actualWidth = imgRatio * actualWidth
                actualHeight = frame.size.height
            } else {
                imgRatio = frame.size.width / actualWidth
                actualHeight = imgRatio * actualHeight
                actualWidth = frame.size.width
            }
        } else {
            imgRatio = frame.size.width / actualWidth
            actualHeight = imgRatio * actualHeight
            actualWidth = frame.size.width
        }
        return  CGSize(width: actualWidth, height: actualHeight)
    }
    
    private func zoomScaleWithNoWhiteSpaces() -> CGFloat{
        let imageViewSize:CGSize  = imageView.bounds.size
        let scrollViewSize:CGSize = bounds.size;
        let widthScale:CGFloat  = scrollViewSize.width / imageViewSize.width
        let heightScale:CGFloat = scrollViewSize.height / imageViewSize.height
        return max(widthScale, heightScale)
    }
}

extension ImageCropScrollView: UIScrollViewDelegate {
    public func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return imageView
    }
    
    public func scrollViewDidZoom(_ scrollView: UIScrollView) {
        updateLayout()
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        gridView.isHidden = false
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        gridView.isHidden = true
    }
    
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        var frame = gridView.frame;
        frame.origin.x = scrollView.contentOffset.x
        frame.origin.y = scrollView.contentOffset.y
        gridView.frame = frame
        
        switch scrollView.pinchGestureRecognizer!.state {
        case .changed:
            gridView.isHidden = false
            break
        case .ended:
            gridView.isHidden = true
            break
        default: break
        }
    }
}

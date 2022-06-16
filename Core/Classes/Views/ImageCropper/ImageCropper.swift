import UIKit
import Combine

public final class ImageCropView: UIView {
    @Published public var isZoomEnabled: Bool = false
    
    public var image: UIImage? {
        didSet { update() }
    }
    private let scroll = ImageCropScrollView()
    
    public init(image: UIImage? = nil) {
        super.init(frame: .zero)
        self.image = image
        setup()
        layout()
        update()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }
    
    private func layout() {
        scroll.embed(in: self)
    }
    
    private func update() {
        scroll.imageToDisplay = image
        isZoomEnabled = !isSquareImage()
    }

    public func croppedImage() -> UIImage {
        captureVisibleRect()
    }
    
    private func captureVisibleRect() -> UIImage {
        
        var croprect = CGRect.zero
        let xOffset = (scroll.imageToDisplay?.size.width)! / scroll.contentSize.width;
        let yOffset = (scroll.imageToDisplay?.size.height)! / scroll.contentSize.height;
        
        croprect.origin.x = scroll.contentOffset.x * xOffset;
        croprect.origin.y = scroll.contentOffset.y * yOffset;
        
        let normalizedWidth = (scroll.frame.width) / (scroll.contentSize.width)
        let normalizedHeight = (scroll.frame.height) / (scroll.contentSize.height)
        
        croprect.size.width = scroll.imageToDisplay!.size.width * normalizedWidth
        croprect.size.height = scroll.imageToDisplay!.size.height * normalizedHeight
        
        let toCropImage = scroll.imageView.image?.fixImageOrientation()
        let cr: CGImage? = toCropImage?.cgImage?.cropping(to: croprect)
        let cropped = UIImage(cgImage: cr!)
        
        return cropped
        
    }
    
    private func isSquareImage() -> Bool{
        let image = scroll.imageToDisplay
        if image?.size.width == image?.size.height { return true }
        else { return false }
    }
}

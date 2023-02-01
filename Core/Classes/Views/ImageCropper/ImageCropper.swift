import UIKit
import Combine

public final class ImageCropView: UIView {
    @Published public var isZoomEnabled: Bool = false
    @Published public var contentOffset: CGPoint = .zero
    private var subscribers = Set<AnyCancellable>()
    
    public var info: ImageCropView.Info {
        Info(cropSize: frame.size,
             zoomScale: scroll.zoomScale,
             minZoomScale: scroll.minimumZoomScale,
             maxZoomScale: scroll.maximumZoomScale,
             contentOffset: scroll.contentOffset,
             bounds: scroll.bounds)
    }
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
        setupObservers()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupObservers() {
        scroll.contentOffsetSubject
            .sink { [weak self] contentOffsetSubject in
                guard let self = self else { return }
                self.contentOffset = contentOffsetSubject
            }.store(in: &subscribers)
    }
    
    private func setup() {
        clipsToBounds = true
    }
    
    private func layout() {
        scroll.embed(in: self)
    }
    
    private func update() {
        scroll.imageToDisplay = image
        isZoomEnabled = !isSquareImage()
        scroll.setZoomScale(scroll.zoomScaleWithNoWhiteSpaces(), animated: false)
    }
    
    public func croppedImage() -> UIImage {
        captureVisibleRect()
    }
    
    public func zoomOut() {
        scroll.setZoomScale(scroll.zoomScaleWithNoWhiteSpaces(), animated: false)
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
    
    public struct Info {
        public let cropSize: CGSize
        public let zoomScale: CGFloat
        public let minZoomScale: CGFloat
        public let maxZoomScale: CGFloat
        public let contentOffset: CGPoint
        public let bounds: CGRect
        
        public init(cropSize:CGSize, zoomScale: CGFloat, minZoomScale: CGFloat, maxZoomScale: CGFloat, contentOffset: CGPoint, bounds: CGRect) {
            self.cropSize = cropSize
            self.zoomScale = zoomScale
            self.minZoomScale = minZoomScale
            self.maxZoomScale = maxZoomScale
            self.contentOffset = contentOffset
            self.bounds = bounds
        }
        
        public init() {
            self.cropSize = .zero
            self.zoomScale = 1
            self.minZoomScale = 1
            self.maxZoomScale = 1
            self.contentOffset = .zero
            self.bounds = .zero
        }
    }
}

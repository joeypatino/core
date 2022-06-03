import UIKit
import AVFoundation

public final class CameraPreview: UIView {
    /// the capture session that this view is displaying
    weak public var session: AVCaptureSession? {
        didSet { previewLayer().session = session }
    }
    
    /// the capture connection for this preview
    public var connection: AVCaptureConnection? { previewLayer().connection }
    
    public init() {
        super.init(frame: .zero)
        setup()
        layout()
    }

    public init(backgroundColor: UIColor) {
        super.init(frame: .zero)
        setup()
        layout()
        self.backgroundColor = backgroundColor
    }
    
    private func setup() {
        previewLayer().session = session
        previewLayer().videoGravity = .resizeAspectFill
        backgroundColor = .black
    }
    
    private func layout() {
        
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Overrides
    override public class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    override public func willMove(toSuperview newSuperview: UIView?) {
        guard newSuperview != nil else { return }
        updateOrientation()
    }
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        updateOrientation()
    }
    
    // MARK: tasks
    private func updateOrientation() {
        guard let currentAvOrientation = currentAvOrientation else { return }
        previewLayer().connection?.videoOrientation = currentAvOrientation
    }
    
    private var currentAvOrientation: AVCaptureVideoOrientation? {
        if let orientation = UIDeviceOrientation.current.avCaptureOrientation {
            return orientation
        } else if let orientation = UIInterfaceOrientation.current.avCaptureOrientation {
            return orientation
        } else {
            return nil
        }
    }
    
    private func previewLayer() -> AVCaptureVideoPreviewLayer {
        guard let previewLayer = layer as? AVCaptureVideoPreviewLayer else { preconditionFailure() }
        return previewLayer
    }
}

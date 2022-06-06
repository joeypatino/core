import UIKit
import AVFoundation

public protocol CameraViewControllerDelegate: AnyObject {
    func viewController(_ viewController: CameraViewController, didCaptureAsset asset: AVAsset, atUrl url: URL)
}

open class CameraViewController: UIViewController {
    public weak var delegate: CameraViewControllerDelegate?
    public var isRecording: Bool { camera.isRecording }
    private let camera = Camera(captureMode: .video(isRecording: false))
    private lazy var preview = view as! CameraPreview
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    open override func loadView() {
        view = CameraPreview()
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    public override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        camera.startRunning()
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        camera.stopRunning()
    }
    
    private func setup() {
        camera.delegate = self
        camera.preview = preview
    }
    
    private func layout() {
        
    }
    
    public func beginVideoCapture() throws {
        guard !isRecording else { throw Camera.Error.invalidState }
        camera.capture()
    }
    
    public func endVideoCapture() throws {
        guard isRecording else { throw Camera.Error.invalidState }
        camera.capture()
    }
}

extension CameraViewController: CameraDelegate {
    public func camera(_ session: Camera, captureModeDidChange captureMode: Camera.CaptureMode) {}
}

extension CameraViewController {
    public func camera(_ session: Camera, didCapturePhoto photo: UIImage, photoURL url: URL) {
        delegate?.viewController(self, didCaptureAsset: AVAsset(url: url), atUrl: url)
    }
}

extension CameraViewController {
    public func cameraVideoCaptureDidBegin(_ session: Camera) {}
    public func cameraVideoCaptureDidFinish(_ session: Camera, withVideoURL url: URL) {
        delegate?.viewController(self, didCaptureAsset: AVAsset(url: url), atUrl: url)
    }
}

extension CameraViewController {
    public func cameraPhotoCaptureDidFail(_ session: Camera, withError error: Camera.Error) {}
}

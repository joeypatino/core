import UIKit
import AVFoundation

public protocol CameraViewControllerDelegate: AnyObject {
    func viewController(_ viewController: CameraViewController, didCaptureAsset asset: AVAsset)
}

open class CameraViewController: UIViewController {
    public weak var delegate: CameraViewControllerDelegate?
    private let camera = Camera(captureMode: .video(isRecording: false))
    private lazy var preview = view as! CameraPreview
    private let captureButton = CaptureButton()
    
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
        captureButton.addTarget(self, action: #selector(onCaptureButtonEditingDidBegin(_:)), for: .editingDidBegin)
        captureButton.addTarget(self, action: #selector(onCaptureButtonEditingDidEnd(_:)), for: .editingDidEnd)
    }
    
    private func layout() {
        view.addAutoLayoutSubview(captureButton)
        captureButton.widthAnchor.equalToConstant(100)
        captureButton.bottomAnchor.equalTo(view.bottomAnchor).constant(-40)
        captureButton.centerXAnchor.equalTo(view.centerXAnchor)
        captureButton.addTarget(self, action: #selector(onCaptureButtonSelected(_:)), for: .touchUpInside)
        
        let delete = UIButton()
        delete.tintColor = .white
        delete.setImage(UIImage(systemName: "delete.left"), for: .normal)
        view.addAutoLayoutSubview(delete)
        delete.widthAnchor.equalToConstant(100)
        delete.heightAnchor.equalToConstant(60)
        delete.leadingAnchor.equalTo(captureButton.trailingAnchor).constant(32)
        delete.centerYAnchor.equalTo(captureButton.centerYAnchor)
        delete.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
    }
    
    @objc private func onCaptureButtonSelected(_ sender: UIButton) {
        if captureButton.isAnimating {
            captureButton.stop()
        } else {
            captureButton.start(duration: 5.0)
        }
    }
    
    @objc private func onCaptureButtonEditingDidBegin(_ sender: UIButton) {
        camera.capture()
    }
    
    @objc private func onCaptureButtonEditingDidEnd(_ sender: UIButton) {
        camera.capture()
        captureButton.addTick()
    }
    
    @objc private func deleteAction(_ sender: UIButton) {
        captureButton.removeTick()
    }
}

extension CameraViewController: CameraDelegate {
    public func camera(_ session: Camera, captureModeDidChange captureMode: Camera.CaptureMode) {}
}

extension CameraViewController {
    public func camera(_ session: Camera, didCapturePhoto photo: UIImage, photoURL url: URL) {
        delegate?.viewController(self, didCaptureAsset: AVAsset(url: url))
    }
}

extension CameraViewController {
    public func cameraVideoCaptureDidBegin(_ session: Camera) {}
    public func cameraVideoCaptureDidFinish(_ session: Camera, withVideoURL url: URL) {
        delegate?.viewController(self, didCaptureAsset: AVAsset(url: url))
    }
}

extension CameraViewController {
    public func cameraPhotoCaptureDidFail(_ session: Camera, withError error: Camera.Error) {}
}

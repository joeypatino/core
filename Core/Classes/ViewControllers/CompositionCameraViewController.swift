import UIKit
import AVKit

public protocol CompositionCameraViewControllerDelegate: AnyObject {
    func viewController(_ viewController: CompositionCameraViewController, didAppendAsset asset: Asset)
    func viewController(_ viewController: CompositionCameraViewController, didDeleteAssset asset: Asset)
}

public class CompositionCameraViewController: UIViewController {
    public weak var delegate: CompositionCameraViewControllerDelegate?
    private let cameraViewController = CameraViewController()
    private let captureButton = CaptureButton(duration: 5)
    private let composition: Composition
    public init(composition: Composition) {
        self.composition = composition
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        layout()
        setup()
    }
    
    private func setup() {
        cameraViewController.delegate = self
        var offset: TimeInterval = 0
        let duration = captureButton.duration
        let timeMarkers = composition.layers.map { layer -> (TimeInterval, TimeInterval) in
            let start = CMTimeGetSeconds(layer.asset.timeRange.start).truncate(to: 1)
            let end = CMTimeGetSeconds(layer.asset.timeRange.end).truncate(to: 1)
            let duration = CMTimeGetSeconds(layer.asset.timeRange.duration).truncate(to: 1)
            let marker = (start + offset, end + start + offset)
            offset += duration
            return marker
        }
        timeMarkers.forEach { captureButton.addSegment(fromValue: $0.0/duration, toValue: min($0.1/duration, 1.0)) }
    }
    
    private func layout() {
        addChildViewController(cameraViewController, addSubview: { $0.embed(in: self.view) })

        view.addAutoLayoutSubview(captureButton)
        captureButton.widthAnchor.equalToConstant(80)
        captureButton.bottomAnchor.equalTo(view.bottomAnchor).constant(-60)
        captureButton.centerXAnchor.equalTo(view.centerXAnchor)
        captureButton.addTarget(self, action: #selector(onCaptureButtonSelected(_:)), for: .touchUpInside)
        captureButton.addTarget(self, action: #selector(onCaptureButtonEditingDidBegin(_:)), for: .editingDidBegin)
        captureButton.addTarget(self, action: #selector(onCaptureButtonEditingDidEnd(_:)), for: .editingDidEnd)

        let delete = UIButton()
        delete.tintColor = .white
        delete.setImage(UIImage(systemName: "delete.left")?.scale(factor: 2, renderingMode: .alwaysTemplate), for: .normal)
        view.addAutoLayoutSubview(delete)
        delete.widthAnchor.equalToConstant(100)
        delete.heightAnchor.equalToConstant(60)
        delete.leadingAnchor.equalTo(captureButton.trailingAnchor).constant(32)
        delete.centerYAnchor.equalTo(captureButton.centerYAnchor)
        delete.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
    }
    
    @objc private func onCaptureButtonSelected(_ sender: UIButton) {
        if cameraViewController.isRecording {
            captureButton.stopAnimation()
        } else {
            captureButton.startAnimation()
        }
    }
    
    @objc private func onCaptureButtonEditingDidBegin(_ sender: UIButton) {
        do {
            try cameraViewController.beginVideoCapture()
        } catch {
            print(error)
        }
    }
    
    @objc private func onCaptureButtonEditingDidEnd(_ sender: UIButton) {
        do {
            try cameraViewController.endVideoCapture()
        } catch {
            print(error)
        }
    }
    
    @objc private func deleteAction(_ sender: UIButton) {
        let lastIndex = composition.layers.count - 1
        if let layer = composition.remove(layerAt: lastIndex) {
            captureButton.removeSegment()
            delegate?.viewController(self, didDeleteAssset: layer.asset)
        }
    }
}

extension CompositionCameraViewController: CameraViewControllerDelegate {
    public func viewController(_ viewController: CameraViewController, didCaptureAsset asset: AVAsset, atUrl url: URL) {
        let asset = Asset(url: url)
        composition.append(layerWithAsset: asset)
        delegate?.viewController(self, didAppendAsset: asset)
    }
}

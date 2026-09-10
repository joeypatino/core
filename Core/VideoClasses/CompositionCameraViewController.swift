import UIKit
import AVKit
import Core

public protocol CompositionCameraViewControllerDelegate: AnyObject {
    func viewController(_ viewController: CompositionCameraViewController, didAppendAsset asset: Asset)
    func viewController(_ viewController: CompositionCameraViewController, didDeleteAssset asset: Asset)
}

public class CompositionCameraViewController: UIViewController {
    public weak var delegate: CompositionCameraViewControllerDelegate?
    private let camera = CameraViewController()
    private let capture = CaptureButton(duration: 5)
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
        camera.delegate = self
        var offset: TimeInterval = 0
        let duration = capture.duration
        let timeMarkers = composition.videoLayers.map { layer -> (TimeInterval, TimeInterval) in
            let start = CMTimeGetSeconds(layer.asset.timeRange.start).truncate(to: 1)
            let end = CMTimeGetSeconds(layer.asset.timeRange.end).truncate(to: 1)
            let duration = CMTimeGetSeconds(layer.asset.timeRange.duration).truncate(to: 1)
            let marker = (start + offset, end + start + offset)
            offset += duration
            return marker
        }
        timeMarkers.forEach { capture.addSegment(fromValue: $0.0/duration, toValue: min($0.1/duration, 1.0)) }
    }

    private func layout() {
        addChildViewController(camera, addSubview: { $0.embed(in: self.view) })

        view.addAutoLayoutSubview(capture)
        capture.widthAnchor.equalToConstant(80)
        capture.bottomAnchor.equalTo(view.bottomAnchor).constant(-60)
        capture.centerXAnchor.equalTo(view.centerXAnchor)
        capture.addTarget(self, action: #selector(onCaptureButtonSelected(_:)), for: .touchUpInside)
        capture.addTarget(self, action: #selector(onCaptureButtonEditingDidBegin(_:)), for: .editingDidBegin)
        capture.addTarget(self, action: #selector(onCaptureButtonEditingDidEnd(_:)), for: .editingDidEnd)

        let delete = UIButton(tintColor: .white)
        delete.setImage(UIImage(systemName: "delete.left")?.scale(factor: 2, renderingMode: .alwaysTemplate), for: .normal)
        view.addAutoLayoutSubview(delete)
        delete.widthAnchor.equalToConstant(100)
        delete.heightAnchor.equalToConstant(60)
        delete.leadingAnchor.equalTo(capture.trailingAnchor).constant(32)
        delete.centerYAnchor.equalTo(capture.centerYAnchor)
        delete.addTarget(self, action: #selector(deleteAction(_:)), for: .touchUpInside)
    }

    @objc private func onCaptureButtonSelected(_ sender: UIButton) {
        if camera.isRecording {
            capture.stopAnimation()
        } else {
            capture.startAnimation()
        }
    }

    @objc private func onCaptureButtonEditingDidBegin(_ sender: UIButton) {
        do {
            try camera.beginVideoCapture()
        } catch {
            print(error)
        }
    }

    @objc private func onCaptureButtonEditingDidEnd(_ sender: UIButton) {
        do {
            try camera.endVideoCapture()
        } catch {
            print(error)
        }
    }

    @objc private func deleteAction(_ sender: UIButton) {
        let lastIndex = composition.videoLayers.count - 1
        if let layer = composition.remove(layerAt: lastIndex) {
            capture.removeSegment()
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

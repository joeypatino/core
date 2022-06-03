import UIKit
import AVKit
import Core
import VideoLab

class VideoEditorPlaygroundViewController: UIViewController {
    private let timeline = VideoTrimmer()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        
    }
    
    private func layout() {
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Open...", for: .normal)
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.heightAnchor.equalToConstant(60)
        button.centerXAnchor.equalTo(view.centerXAnchor)
        button.centerYAnchor.equalTo(view.centerYAnchor)
        button.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
        
        view.addAutoLayoutSubview(timeline)
        timeline.bottomAnchor.equalTo(view.bottomAnchor).constant(-40)
        timeline.leadingAnchor.equalTo(view.leadingAnchor).constant(16)
        timeline.trailingAnchor.equalTo(view.trailingAnchor).constant(-16)
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        let viewController = CameraViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension VideoEditorPlaygroundViewController: CameraViewControllerDelegate {
    func viewController(_ viewController: CameraViewController, didCaptureAsset asset: AVAsset) {
        print(#function, asset)
    }
}

// composition      -> RenderComposition(layers:_)
//      - layer            -> RenderLayer(source:_)    <- AVAssetSource

private extension RenderLayer {
    convenience init(asset: AVAsset) {
        let source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        self.init(timeRange: source.selectedTimeRange, source: source)
    }
}

private extension RenderComposition {
    func addLayer(withAsset asset: AVAsset) {
        let source = AVAssetSource(asset: asset)
        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        var timeRange = source.selectedTimeRange
        if let lastLayer = layers.last {
            timeRange.start = CMTimeRangeGetEnd(lastLayer.timeRange)
            layers.append(RenderLayer(timeRange: timeRange, source: source))
        } else {
            layers.append(RenderLayer(timeRange: timeRange, source: source))
        }
    }
}

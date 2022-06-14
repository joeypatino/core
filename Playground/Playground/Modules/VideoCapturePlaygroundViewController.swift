import UIKit
import AVKit
import Core
import VideoLab

class VideoCapturePlaygroundViewController: UIViewController {
    let timeline = VideoTrimmer()
    lazy var composition = RenderComposition()
    lazy var videoLab = VideoLab(renderComposition: composition)
    lazy var videoPlayerViewController = VideoPlayerViewController(playerItem: videoLab.makePlayerItem())
    
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
        composition.backgroundColor = .clearColor
        composition.renderSize = CGSize(width: 720, height: 1280)
    }
    
    private func layout() {
        addChildViewController(videoPlayerViewController) { $0.embed(in: self.view) }
        
        view.addAutoLayoutSubview(timeline)
        timeline.bottomAnchor.equalTo(view.bottomAnchor).constant(-80)
        timeline.leadingAnchor.equalTo(view.leadingAnchor).constant(8)
        timeline.trailingAnchor.equalTo(view.trailingAnchor).constant(-8)
        
        let button = UIButton()
        button.setTitleColor(.white, for: .normal)
        button.setTitle("Record...", for: .normal)
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.heightAnchor.equalToConstant(60)
        button.bottomAnchor.equalTo(timeline.topAnchor).constant(-16)
        button.trailingAnchor.equalTo(view.trailingAnchor).constant(-32)
        button.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
    }
    
    private func updateComposition() {
        
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        let viewController = CameraViewController()
        viewController.delegate = self
        present(viewController, animated: true)
    }
}

extension VideoCapturePlaygroundViewController: CameraViewControllerDelegate {
    func viewController(_ viewController: CameraViewController, didCaptureAsset asset: AVAsset, atUrl url: URL) {
        composition.addLayer(with: asset)
        videoPlayerViewController.playerItem = videoLab.makePlayerItem()
        timeline.imageGenerator = videoLab.makeImageGenerator()
    }
}

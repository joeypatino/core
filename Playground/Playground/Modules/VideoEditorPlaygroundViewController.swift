import UIKit
import AVKit
import Core
import VideoLab

class VideoEditorPlaygroundViewController: UIViewController {
    let trimmer = VideoTrimmer()
    lazy var timeline = VideoTimelineView(composition: composition)
    lazy var composition = Composition() {
        didSet { updateComposition() }
    }
    lazy var videoPlayerViewController = VideoPlayerViewController(playerItem: composition.layers.isEmpty ? AVPlayerItem(asset: AVComposition()) : composition.playerItem)
    @Storage (key:"composition_name", defaultValue: nil) private var compositionName: String?
    
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        guard let name = compositionName else { return }
        let url = FileManager.default.documentsDirectory.appendingPathComponent("\(name).dat")
        guard let data = FileManager.default.contents(atPath: url.path) else { compositionName = nil; return }
        do {
            composition = try JSONDecoder().decode(Composition.self, from: data)
            videoPlayerViewController.playerItem = composition.playerItem
            trimmer.imageGenerator = composition.imageGenerator
        } catch {
            try? FileManager.default.removeItem(at: url)
            compositionName = nil
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        guard composition.layers.count > 0 else { return }
        let encoded = try! JSONEncoder().encode(composition)
        let name = compositionName ?? UUID().uuidString
        let url = FileManager.default.documentsDirectory.appendingPathComponent("\(name).dat")
        if FileManager.default.createFile(atPath: url.path, contents: encoded, attributes: nil) {
            compositionName = name
        } else {
            compositionName = nil
        }
    }
    
    private func setup() {
        videoPlayerViewController.timeAndDurationObserver = { [weak self] time, duration in
            guard let self = self else { return }
            self.timeline.updateCurrentTime(time)
        }
        videoPlayerViewController.playbackComplete = { [weak self] _ in
            guard let self = self else { return }
            self.timeline.jumpToStart()
        }
        composition.renderSize = CGSize(width: 720, height: 1280)
        trimmer.borderColor = UIColor(hex: "#E9435A")
        timeline.delegate = self
    }
    
    private func layout() {
        addChildViewController(videoPlayerViewController) { $0.embed(in: self.view) }

        view.addAutoLayoutSubview(timeline)
        timeline.bottomAnchor.equalTo(view.bottomAnchor).constant(-80)
        timeline.leadingAnchor.equalTo(view.leadingAnchor).constant(16)
        timeline.trailingAnchor.equalTo(view.trailingAnchor).constant(-16)

        view.addAutoLayoutSubview(trimmer)
        trimmer.bottomAnchor.equalTo(timeline.topAnchor).constant(-20)
        trimmer.leadingAnchor.equalTo(view.leadingAnchor)
        trimmer.trailingAnchor.equalTo(view.trailingAnchor)
        
        let recordButton = UIButton()
        recordButton.tintColor = .red
        recordButton.setTitleColor(.white, for: .normal)
        recordButton.setTitle("Record", for: .normal)
        recordButton.setAttributedTitle(NSAttributedString(string: "Record", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.white]), for: .normal)
        recordButton.setImage(UIImage(systemName: "record.circle")?.scale(factor: 2).withRenderingMode(.alwaysTemplate), for: .normal)
        recordButton.centerTextAndImage(imageAboveText: true, spacing: 8)
        view.addAutoLayoutSubview(recordButton)
        recordButton.widthAnchor.equalToConstant(60)
        recordButton.heightAnchor.equalToConstant(60)
        recordButton.bottomAnchor.equalTo(trimmer.topAnchor).constant(-16)
        recordButton.trailingAnchor.equalTo(view.trailingAnchor).constant(-8)
        recordButton.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
        
        let clearButton = UIButton()
        clearButton.tintColor = .white
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setAttributedTitle(NSAttributedString(string: "Clear", attributes: [.font:UIFont.systemFont(ofSize: 14, weight: .medium), .foregroundColor: UIColor.white]), for: .normal)
        clearButton.setImage(UIImage(systemName: "xmark.square")?.scale(factor: 2).withRenderingMode(.alwaysTemplate), for: .normal)
        clearButton.centerTextAndImage(imageAboveText: true, spacing: 8)
        view.addAutoLayoutSubview(clearButton)
        clearButton.widthAnchor.equalToConstant(60)
        clearButton.heightAnchor.equalToConstant(60)
        clearButton.bottomAnchor.equalTo(trimmer.topAnchor).constant(-16)
        clearButton.leadingAnchor.equalTo(view.leadingAnchor).constant(8)
        clearButton.addTarget(self, action: #selector(resetCompositionAction(_:)), for: .touchUpInside)
    }
    
    private func updateComposition() {
        timeline.composition = composition
        videoPlayerViewController.playerItem = composition.playerItem
        trimmer.imageGenerator = composition.imageGenerator
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        let viewController = CompositionCameraViewController(composition: composition)
        viewController.delegate = self
        present(viewController, animated: true)
    }
    
    @objc private func resetCompositionAction(_ sender: UIButton) {
        composition = Composition()
        updateComposition()
    }
}

extension VideoEditorPlaygroundViewController: CompositionCameraViewControllerDelegate {
    public func viewController(_ viewController: CompositionCameraViewController, didAppendAsset asset: Asset) {
        updateComposition()
    }
    
    public func viewController(_ viewController: CompositionCameraViewController, didDeleteAssset asset: Asset) {
        updateComposition()
    }
}

extension VideoEditorPlaygroundViewController: VideoTimelineViewDelegate {
    public func view(_ videoTimeline: VideoTimelineView, didSelectAsset asset: Asset) {
        let url = Bundle.main.url(forResource: "audio_sample_1", withExtension: "mp3")!
        let asset = Asset(url: url)
        composition.setAudio(layerWithAsset: asset, timeRange: CMTimeRange(start: .zero, duration: CMTime(seconds: 5.0, preferredTimescale: CMTimeScale(600))))
//        DispatchQueue.main.asyncAfter(delay: 0.5) {
            self.updateComposition()
//        }

        let time = composition.timeRange(forAsset: asset).start
        videoPlayerViewController.seek(to: time)
        DispatchQueue.main.asyncAfter(delay: 0.15) {
            if self.composition.layers.firstIndex(where: { $0.asset == asset }) == 0 {
                self.timeline.updateCurrentTime(CMTimeAdd(.zero, CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(30))))
            }
        }

        // The bug in the timeline...
        // when scrolling through the timeline, the periodic time observer responds with CMTime.zero in between clips
        // what is the cause?
        // possibly because i'm scrubbing through a AVComposition and the start / end times of the assets do not line up
        // perfectly?
        // test this by creating a new composition with many assets, then scrubbing through and looking for the bug
        // if this doesn't appear, then save the clip and then load it again and scrub through.... Does it happen now?
        
        // if this starts to cause it then the issue is being caused during the saving or loading process.
        
        // if it happens with new compositions, then look into how assets are added to the composition
        
        // if all else fails, try to only setup boundary time observers, and update these when the composition changes.
        // this *should* prevent the issues seen but will require more careful maintaince to keep the observers up to date.
    }
    
    public func view(_ videoTimeline: VideoTimelineView, didEditComposition composition: Composition) {
        updateComposition()
    }
}


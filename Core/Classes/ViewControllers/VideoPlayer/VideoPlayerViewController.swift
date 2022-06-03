import UIKit
import AVKit

public protocol VideoPlayerControls: UIView {
    var player: AVPlayer? { get set }
    var status: AVPlayerItem.Status { get set }
    var timeControlStatus: AVPlayer.TimeControlStatus { get set }
    var playbackRate: Float { get set }
    var duration: CMTime { get set }
    var timeAndDuration: (CMTime, CMTime) { get set }
    var loadedTimeRanges: [NSValue] { get set }
}

open class VideoPlayerViewController: UIViewController {
    private let playerViewController = AVPlayerViewController()
    private let activity = UIActivityIndicatorView(style: .medium)
    private lazy var controls: VideoPlayerControls = GenericVideoPlayerControls(player: player)
    
    private let asset: AVAsset
    private let playerItem: AVPlayerItem
    private let player: AVPlayer
    private var timeObserver: Any?
    private var status: AVPlayerItem.Status {
        get { controls.status }
        set { controls.status = newValue }
    }
    private var timeControlStatus: AVPlayer.TimeControlStatus {
        get { controls.timeControlStatus }
        set { controls.timeControlStatus = newValue }
    }
    
    public init(asset: AVAsset) {
        self.asset = asset
        self.playerItem = AVPlayerItem(asset: asset)
        self.player = AVPlayer(playerItem: playerItem)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus))
        player.removeObserver(self, forKeyPath: #keyPath(AVPlayer.rate))
        timeObserver.map { player.removeTimeObserver($0) }
    }
    
    open override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new], context: nil)
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] progress in
            guard let self = self else { return }
            // Get passed time for video (minute & seconds)
            if let duration = self.player.currentItem?.duration {
                self.controls.timeAndDuration = (progress, duration)
            }
        }
        
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        addChildViewController(playerViewController) { $0.embed(in: self.view) }
        playerViewController.updatesNowPlayingInfoCenter = false
        controls.embed(in: view, usingSafeAreaLayoutGuides: true)
    }
    
    private func layout() {
        
    }
    
    public override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(AVPlayer.rate) {
            DispatchQueue.main.async { self.controls.playbackRate = self.player.rate }
        } else if keyPath == #keyPath(AVPlayer.timeControlStatus) {
            DispatchQueue.main.async { self.timeControlStatus = self.player.timeControlStatus }
        } else if keyPath == #keyPath(AVPlayerItem.status) {
            DispatchQueue.main.async { self.status = self.playerItem.status }
        } else if keyPath == #keyPath(AVPlayerItem.loadedTimeRanges) {
            if let duration = player.currentItem?.duration {
                DispatchQueue.main.async { self.controls.duration = duration }
                if let timeRanges = player.currentItem?.loadedTimeRanges {
                    DispatchQueue.main.async { self.controls.loadedTimeRanges = timeRanges }
                }
            }
        }
    }
}

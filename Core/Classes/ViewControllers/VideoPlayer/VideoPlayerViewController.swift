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
    
    func show()
    func hide()
}

open class VideoPlayerViewController: UIViewController {
    public var playerItem: AVPlayerItem {
        didSet {
            unregisterPlayerItemObservers(oldValue)
            asset = playerItem.asset
            player.replaceCurrentItem(with: playerItem)
            registerPlayerItemObservers(playerItem)
        }
    }
    public var videoGravity: AVLayerVideoGravity {
        get { playerViewController.videoGravity }
        set { playerViewController.videoGravity = newValue }
    }

    public var playbackComplete: (CMTime) -> Void = { _ in }
    public var timeAndDurationObserver: (CMTime, CMTime) -> Void = { _, _ in }
    private let playerViewController = AVPlayerViewController()
    private let activity = UIActivityIndicatorView(style: .medium)
    public lazy var controls: VideoPlayerControls = GenericVideoPlayerControls(player: player) {
        didSet {
            oldValue.removeFromSuperview()
            controls.embed(in: view, usingSafeAreaLayoutGuides: false)
        }
    }
    
    private var lastProgress: CMTime = .zero
    private var asset: AVAsset
    private var player: AVPlayer
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
    
    public init(playerItem: AVPlayerItem) {
        self.asset = playerItem.asset
        self.playerItem = playerItem
        self.player = AVPlayer(playerItem: playerItem)
        super.init(nibName: nil, bundle: nil)
    }
    
    required public init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        unregisterPlayerItemObservers(playerItem)
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
        NotificationCenter.default.addObserver(self, selector: #selector(playerEndedPlaying), name: .AVPlayerItemDidPlayToEndTime, object: nil)
        registerPlayerItemObservers(playerItem)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.rate), options: [.new], context: nil)
        player.addObserver(self, forKeyPath: #keyPath(AVPlayer.timeControlStatus), options: [.new], context: nil)
        timeObserver = player.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 30), queue: .main) { [weak self] progress in
            guard let self = self else { return }
            // Get passed time for video (minute & seconds)
            //            var adjustedProgress = progress
            //            if adjustedProgress == .zero {
            //                let hundreth = CMTime(seconds: 0.01, preferredTimescale: CMTimeScale(600))
            //                adjustedProgress = CMTimeAdd(.zero, hundreth)
            //            }
            //            if adjustedProgress != .zero {
            //                self.lastProgress = adjustedProgress
            //            }
            if progress != .zero {
                self.lastProgress = progress
            }
            
            if let duration = self.player.currentItem?.duration {
                self.controls.timeAndDuration = (self.player.currentTime(), duration)
                self.timeAndDurationObserver(self.lastProgress, duration)
            }
        }
        
        playerViewController.player = player
        playerViewController.showsPlaybackControls = false
        playerViewController.updatesNowPlayingInfoCenter = false
        
    }
    
    private func layout() {
        addChildViewController(playerViewController) { $0.embed(in: self.view) }
        controls.embed(in: view, usingSafeAreaLayoutGuides: false)
    }
    
    public func play() {
        player.play()
    }
    
    public func pause() {
        player.pause()
    }
    
    public func seek(to time: CMTime) {
        player.seek(to: time, toleranceBefore: .zero, toleranceAfter: .zero)
    }
    
    private func unregisterPlayerItemObservers(_ playerItem: AVPlayerItem) {
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges))
        playerItem.removeObserver(self, forKeyPath: #keyPath(AVPlayerItem.status))
    }
    
    private func registerPlayerItemObservers(_ playerItem: AVPlayerItem) {
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.status), options: [.new], context: nil)
        playerItem.addObserver(self, forKeyPath: #keyPath(AVPlayerItem.loadedTimeRanges), options: [.new], context: nil)
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
    
    @objc private func playerEndedPlaying(_ notification: Notification) {
        DispatchQueue.main.async {
            self.playbackComplete(self.player.currentTime())
            self.player.seek(to: CMTime.zero)
            self.lastProgress = .zero
            self.controls.show()
        }
    }
}

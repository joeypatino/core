import UIKit
import AVKit

public final class DisabledVideoPlayerControls: UIView, VideoPlayerControls {
    public var player: AVPlayer?
    
    public var status: AVPlayerItem.Status = .readyToPlay
    
    public var timeControlStatus: AVPlayer.TimeControlStatus = .playing
    
    public var playbackRate: Float = 1.0
    
    public var duration: CMTime = .zero
    
    public var timeAndDuration: (CMTime, CMTime) = (.zero, .zero)
    
    public var loadedTimeRanges: [NSValue] = []
    
    public func show() {
        
    }
    
    public func hide() {
        
    }
}

public final class GenericVideoPlayerControls: UIView, VideoPlayerControls {
    public weak var player: AVPlayer?
    public var status: AVPlayerItem.Status = .unknown {
        didSet {
            switch status {
            case .unknown:
                playPauseButton.isHidden = true
                activity.startAnimating()
            default:
                playPauseButton.isHidden = false
                activity.stopAnimating()
            }
        }
    }
    public var timeControlStatus: AVPlayer.TimeControlStatus = .paused {
        didSet {
            switch timeControlStatus {
            case .waitingToPlayAtSpecifiedRate:
                activity.startAnimating()
            default:
                status == .unknown
                ? activity.startAnimating()
                : activity.stopAnimating()
            }
        }
    }
    public var playbackRate: Float = 0 {
        didSet {
            let isPlaying = playbackRate != 0.0
            playPauseButton.setImage(isPlaying
                                     ? UIImage(systemName: "pause.fill")?.scale(factor: 1.25, renderingMode: .alwaysTemplate)
                                     : UIImage(systemName: "play.fill")?.scale(factor: 1.25, renderingMode: .alwaysTemplate), for: .normal)
        }
    }
    public var duration: CMTime = .zero {
        didSet {
            let seconds = CMTimeGetSeconds(duration)
            guard !seconds.isNaN else { return }
            let secondText = String(format: "%02d", Int(seconds) % 60)
            let minuteText = String(format: "%02d", Int(seconds) / 60)
            videoLengthLabel.text = "\(minuteText):\(secondText)"
        }
    }
    public var timeAndDuration: (CMTime, CMTime) = (.zero, .zero) {
        didSet {
             
            let durationSeconds = CMTimeGetSeconds(timeAndDuration.1)
            let seconds = CMTimeGetSeconds(timeAndDuration.0)
            let progress = Float(seconds/durationSeconds)
            if !timeSlider.isTracking { timeSlider.value = progress }
            let secondText = String(format: "%02d", Int(seconds) % 60)
            let minuteText = String(format: "%02d", Int(seconds) / 60)
            elapsedTimeLabel.text = "\(minuteText):\(secondText)"
            if progress >= 1.0 {
                timeSlider.value = 0.0
                elapsedTimeLabel.text = "00:00"
            }
        }
    }
    public var loadedTimeRanges: [NSValue] = [] {
        didSet {
            guard let timeRange: CMTimeRange = loadedTimeRanges.first?.timeRangeValue else { return }
            let startTime = CMTimeGetSeconds(timeRange.start)
            let loadedDuration = CMTimeGetSeconds(timeRange.duration)
            let bufferLoadedTime: CGFloat = CGFloat(startTime + loadedDuration) / 100
            if bufferLoadedTime <= 1.0 {
                bufferLoadRangeLayer.strokeEnd = bufferLoadedTime
            }
        }
    }
    
    private let skipDuration: TimeInterval = 3.0
    
    private let container = UIView(backgroundColor: UIColor(white: 0, alpha: 0.3))
    
    private lazy var playPauseButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(systemName: "play.fill")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(playPausePress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var forwardButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(systemName: "forward.fill")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(forwardPress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private lazy var rewindButton: UIButton = {
        let btn = UIButton(type: .system)
        let icon = UIImage(systemName: "backward.fill")?.withRenderingMode(.alwaysTemplate)
        btn.setImage(icon, for: .normal)
        btn.tintColor = .white
        btn.addTarget(self, action: #selector(rewindPress(_:)), for: .touchUpInside)
        return btn
    }()
    
    private var videoLengthLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "00:00"
        label.textAlignment = .right
        return label
    }()
    
    private var elapsedTimeLabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.text = "00:00"
        return label
    }()
    
    private var errorlabel: UILabel = {
        let label = UILabel(frame: .zero)
        label.textColor = .white
        label.numberOfLines = 0
        label.font = UIFont.boldSystemFont(ofSize: 15)
        label.text = "Unknown error, please try again later."
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    private lazy var timeSlider: UISlider = {
        let slider = UISlider(frame: .zero)
        slider.tintColor = .white
        slider.minimumTrackTintColor = .red
        slider.maximumTrackTintColor = UIColor(white: 1, alpha: 0.4)
        slider.setThumbImage(UIImage(systemName: "circle.fill"), for: .normal)
        slider.addTarget(self, action: #selector(handleSlider(_:)), for: .valueChanged)
        return slider
    }()
    
    private var activity: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.startAnimating()
        return spinner
    }()
    
    private lazy var setupBufferLoadAnimation: CABasicAnimation = {
        let basicAnimation = CABasicAnimation(keyPath: "strokeEnd")
        basicAnimation.fromValue = 0
        basicAnimation.repeatCount = 0
        basicAnimation.fillMode = .forwards
        basicAnimation.isRemovedOnCompletion = false
        return basicAnimation
    }()
    
    private lazy var bufferLoadRangeLayer: CAShapeLayer = {
        let animationLayer = CAShapeLayer()
        animationLayer.lineWidth = 3
        animationLayer.strokeColor = UIColor.yellow.cgColor
        animationLayer.lineCap = .square
        animationLayer.strokeEnd = 0
        
        let path = UIBezierPath()
        path.move(to: CGPoint(x: timeSlider.bounds.minX + 3, y: timeSlider.bounds.midY))
        path.addLine(to: CGPoint(x: timeSlider.bounds.maxX, y: timeSlider.bounds.midY))
        animationLayer.path = path.cgPath
        return animationLayer
    }()
    
    public init(player: AVPlayer) {
        self.player = player
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
    }
    
    private func layout() {
        container.embed(in: self)
        container.addAutoLayoutSubview(activity)
        container.addAutoLayoutSubview(rewindButton)
        container.addAutoLayoutSubview(playPauseButton)
        container.addAutoLayoutSubview(forwardButton)
        container.addAutoLayoutSubview(elapsedTimeLabel)
        container.addAutoLayoutSubview(timeSlider)
        container.addAutoLayoutSubview(videoLengthLabel)
        container.addAutoLayoutSubview(errorlabel)
        
        NSLayoutConstraint.activate([
            activity.centerXAnchor.constraint(equalTo: centerXAnchor),
            activity.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Rewind button constraints
            rewindButton.widthAnchor.constraint(equalToConstant: 35),
            rewindButton.heightAnchor.constraint(equalToConstant: 35),
            rewindButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: -75),
            rewindButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Play pause button constraints
            playPauseButton.widthAnchor.constraint(equalToConstant: 40),
            playPauseButton.heightAnchor.constraint(equalToConstant: 40),
            playPauseButton.centerXAnchor.constraint(equalTo: centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Rewind button constraints
            forwardButton.widthAnchor.constraint(equalToConstant: 35),
            forwardButton.heightAnchor.constraint(equalToConstant: 35),
            forwardButton.centerXAnchor.constraint(equalTo: centerXAnchor, constant: 75),
            forwardButton.centerYAnchor.constraint(equalTo: centerYAnchor),
            
            // Total time label
            elapsedTimeLabel.widthAnchor.constraint(equalToConstant: 45),
            elapsedTimeLabel.heightAnchor.constraint(equalToConstant: 25),
            elapsedTimeLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 8),
            elapsedTimeLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            
            // Total time label
            videoLengthLabel.widthAnchor.constraint(equalToConstant: 45),
            videoLengthLabel.heightAnchor.constraint(equalToConstant: 25),
            videoLengthLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -8),
            videoLengthLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            
            // Slider constraints
            timeSlider.leadingAnchor.constraint(equalTo: elapsedTimeLabel.trailingAnchor),
            timeSlider.trailingAnchor.constraint(equalTo: videoLengthLabel.leadingAnchor),
            timeSlider.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -40),
            timeSlider.heightAnchor.constraint(equalToConstant: 25),
            
            // Play pause button constraints
            errorlabel.widthAnchor.constraint(equalToConstant: 200),
            errorlabel.heightAnchor.constraint(equalToConstant: 70),
            errorlabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            errorlabel.centerYAnchor.constraint(equalTo: centerYAnchor),
        ])
    }
    
    private func showControls() {
        guard self.container.isHidden else { return }
        handleTap()
    }
    
    private func hideControls() {
        guard !self.container.isHidden else { return }
        handleTap()
    }
    
    public func show() {
        showControls()
    }
    
    public func hide() {
        hideControls()
    }

    @objc private func handleTap() {
        UIView.transition(with: self, duration: 0.5, options: .transitionCrossDissolve, animations: {
            self.container.isHidden = !self.container.isHidden
        })
    }
    
    @objc private func playPausePress(_ sender: UIButton) {
        let isPlaying = player?.rate != 0.0
        isPlaying ? player?.pause() : player?.play()
    }
    
    @objc private func forwardPress(_ sender: UIButton) {
        if let currentTime = player?.currentTime(), let duration = player?.currentItem?.duration {
            var newTime = CMTimeGetSeconds(currentTime) + skipDuration
            if newTime >= CMTimeGetSeconds(duration) {
                newTime = CMTimeGetSeconds(duration)
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    @objc private func rewindPress(_ sender: UIButton) {
        if let currentTime = player?.currentTime() {
            var newTime = CMTimeGetSeconds(currentTime) - skipDuration
            if newTime <= 0 {
                newTime = 0
            }
            player?.seek(to: CMTime(value: CMTimeValue(newTime * 1000), timescale: 1000))
        }
    }
    
    @objc private func handleSlider(_ sender: UISlider) {
        if let duration = player?.currentItem?.duration {            
            let totalSeconds = CMTimeGetSeconds(duration)
            let value = totalSeconds * Float64(timeSlider.value)
            let seekTime = CMTime(value: Int64(value * 1000), timescale: 1000)
            player?.seek(to: seekTime)
        }
    }
}

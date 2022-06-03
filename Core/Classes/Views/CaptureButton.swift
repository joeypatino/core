import UIKit

public final class CaptureButton: RoundButton {
    public var color: UIColor = .red {
        didSet { insetLayer.backgroundColor = color.cgColor }
    }
    public var ringWidth: CGFloat = 10 {
        didSet {
            updateInset()
            updateCaptureRingUnfilled()
            updateCaptureRing()
            updateStrokeTicks()
        }
    }
    public var isAnimating: Bool {
        captureRing.animation(forKey: Self.animationKey) != nil && captureRing.speed != 0.0
    }
    
    public private(set) var isFinished: Bool = false
    
    public var captureDuration: TimeInterval = 10 {
        didSet { captureRingAnimation.duration = captureDuration }
    }
    
    private lazy var insetLayer: CALayer = {
        let insetLayer = CALayer()
        insetLayer.backgroundColor = color.cgColor
        return insetLayer
    }()
    private var captureRing = CAShapeLayer()
    private lazy var captureRingUnfilled: CAShapeLayer = {
        let captureRing = CAShapeLayer()
        captureRing.lineWidth = ringWidth * 2
        captureRing.fillColor = nil
        captureRing.strokeColor = color.withAlphaComponent(0.2).cgColor
        captureRing.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        return captureRing
    }()
    private lazy var captureRingAnimation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0.0
        animation.toValue = 1.0
        animation.duration = captureDuration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        animation.delegate = self
        return animation
    }()
    
    private var captureTicks: [CAShapeLayer] = []
    
    override public var bounds: CGRect {
        didSet {
            updateInset()
            updateCaptureRingUnfilled()
            updateCaptureRing()
            updateStrokeTicks()
        }
    }
    
    convenience public init() {
        self.init(frame: .zero)
        setup()
    }
    
    private func setup() {
        setupCaptureRing()
        layer.addSublayer(insetLayer)
        layer.addSublayer(captureRingUnfilled)
        layer.addSublayer(captureRing)
    }
    
    private func setupCaptureRing() {
        captureRing.strokeStart = 0
        captureRing.strokeEnd = 0
        captureRing.lineWidth = ringWidth
        captureRing.fillColor = UIColor.clear.cgColor
        captureRing.strokeColor = color.withAlphaComponent(0.7).cgColor
        captureRing.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func updateInset() {
        insetLayer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        insetLayer.bounds = bounds
        insetLayer.cornerRadius = insetLayer.bounds.width / 2
        insetLayer.position = bounds.center
    }
    
    private func updateCaptureRingUnfilled() {
        captureRingUnfilled.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        captureRingUnfilled.path = UIBezierPath(roundedRect: bounds.insetBy(dx: -ringWidth, dy: -ringWidth), cornerRadius: bounds.size.width / 2).cgPath
        captureRingUnfilled.position = bounds.center
        captureRingUnfilled.bounds = bounds
        captureRingUnfilled.cornerRadius = bounds.width / 2
    }
    
    private func updateCaptureRing() {
        captureRing.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        captureRing.path = UIBezierPath(roundedRect: bounds.insetBy(dx: -ringWidth*1.5, dy: -ringWidth*1.5), cornerRadius: bounds.size.width / 2).cgPath
        captureRing.position = bounds.center
        captureRing.bounds = bounds
        captureRing.cornerRadius = bounds.width / 2
    }
    
    private func updateStrokeTicks() {
        captureTicks.forEach {
            $0.fillColor = nil
            $0.lineWidth = ringWidth
            $0.strokeColor = UIColor.white.cgColor
            $0.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            $0.path = UIBezierPath(roundedRect: bounds.insetBy(dx: -ringWidth*1.5, dy: -ringWidth*1.5), cornerRadius: bounds.size.width / 2).cgPath
            $0.position = bounds.center
            $0.bounds = bounds
            $0.cornerRadius = bounds.width / 2
        }
    }
    
    // MARK: Public
    
    public func addTick() {
        let stroke = captureRing.presentation()?.strokeEnd ?? 0
        let tickLayer = CAShapeLayer()
        tickLayer.strokeStart = stroke - 0.01
        tickLayer.strokeEnd = stroke
        captureTicks.append(tickLayer)
        layer.addSublayer(tickLayer)
        updateStrokeTicks()
    }
    
    public func removeTick() {
        guard !isAnimating else { return }
        
        guard let tick = captureTicks.last else { return }
        // user only captured a single segment, with the end point at the natural end fo the recording
        // we should back up to the next previous segment if available
        captureTicks.removeLast()
        tick.removeFromSuperlayer()
        
        duplicateCaptureRingAndRemoveOldCaptureRing()
        
        // if there's another previous tick the use it for the captureRing strokeEnd
        guard let tick = captureTicks.last else {
            // else set the captureRing to strokeEnd = 0.0 (the start)
            captureRing.strokeEnd = 0.0
            return
        }
        captureRing.strokeEnd = tick.strokeEnd
    }
    
    public func start(duration: TimeInterval = 10.0) {
        guard !isFinished else { return }
        sendActions(for: .editingDidBegin)
        captureDuration = duration
        startAnimation()
    }
    
    public func stop() {
        sendActions(for: .editingDidEnd)
        pauseAnimation()
    }
    
    public func reset() {
        resetAnimation()
        captureRing.strokeStart = 0.0
        captureRing.strokeEnd = 0.0
        isFinished = false
    }
    
    static let animationKey = "strokeEndAnimation"
    
    func duplicateCaptureRingAndRemoveOldCaptureRing() {
        // store old settings
        let beginTime = captureRing.beginTime
        let speed = captureRing.speed
        let timeOffset = captureRing.timeOffset
        
        // remove old capture ring from view
        captureRing.removeFromSuperlayer()
        captureRing.removeAllAnimations()
        
        // create new ref and make visible
        captureRing = CAShapeLayer()
        layer.insertSublayer(captureRing, above: captureRingUnfilled)
        
        // update settings for new ref
        setupCaptureRing()
        updateCaptureRing()

        // restore old settings
        captureRing.beginTime = beginTime
        captureRing.speed = speed
        captureRing.timeOffset = timeOffset

        resetAnimation()
    }
    
    func startAnimation() {
        if let animationKeys = captureRing.animationKeys(), animationKeys.contains(Self.animationKey) {
            let pausedTime = captureRing.timeOffset
            captureRing.speed = 1.0
            captureRing.timeOffset = 0.0
            captureRing.beginTime = 0.0
            let timeSincePause = captureRing.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            captureRing.beginTime = timeSincePause
        } else {
            captureRing.add(captureRingAnimation, forKey: Self.animationKey)
        }
    }
    
    func resetAnimation() {
        captureRing.removeAnimation(forKey: Self.animationKey)
    }
    
    func pauseAnimation() {
        let pausedTime = captureRing.convertTime(CACurrentMediaTime(), from: nil)
        captureRing.speed = 0.0
        captureRing.timeOffset = pausedTime
    }
}

extension CaptureButton: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        isFinished = true
        stop()
    }
}

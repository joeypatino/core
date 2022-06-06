import UIKit

public final class CaptureButton: RoundButton {
    public var duration: TimeInterval { ringView.duration }
    private let ringView: RingView
 
    public init(duration: TimeInterval = 5) {
        ringView = RingView(duration: duration)
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        ringView.delegate = self
    }
    
    private func layout() {
        ringView.embed(in: self)
    }
    
    public func isAnimating() -> Bool {
        ringView.isAnimating()
    }
    
    public func startAnimation() {
        ringView.startAnimation()
    }
    
    public func stopAnimation() {
        ringView.stopAnimation()
    }

    public func addSegment(fromValue: CGFloat = 0.0, toValue: CGFloat = 1.0) {
        ringView.addSegment(fromValue: fromValue, toValue: toValue)
    }
    
    public func removeSegment() {
        ringView.removeSegment()
    }
}

extension CaptureButton: RingViewDelegate {
    public func viewDidStartAnimation(_ view: RingView) {
        sendActions(for: .editingDidBegin)
    }
    
    public func viewDidStopAnimation(_ view: RingView) {
        sendActions(for: .editingDidEnd)
    }
    
    public func viewDidCompleteAnimation(_ view: RingView) {
        sendActions(for: .editingDidEnd)
    }
}

public protocol RingViewDelegate: AnyObject {
    func viewDidStartAnimation(_ view: RingView)
    func viewDidStopAnimation(_ view: RingView)
    func viewDidCompleteAnimation(_ view: RingView)
}

public final class RingView: UIView {
    public weak var delegate: RingViewDelegate?
    public var color: UIColor {
        didSet { rings.forEach { ring in ring.color = color } }
    }
    public var unfilledColor: UIColor {
        didSet { rings.forEach { ring in ring.color = color }; unfilledRing.strokeColor = unfilledColor.cgColor }
    }
    public var width: CGFloat {
        didSet { rings.forEach { ring in ring.width = width }; unfilledRing.lineWidth = width * 2 }
    }
    public var duration: TimeInterval
    public private(set) var isComplete: Bool = false {
        didSet {
            guard isComplete else { return }
            delegate?.viewDidCompleteAnimation(self)
        }
    }
    
    private var rings: [RingSegmentView] = []
    private let unfilledRing = CAShapeLayer()
    public init(color: UIColor = UIColor.red.withAlphaComponent(0.7), unfilledColor: UIColor = UIColor.red.withAlphaComponent(0.2), width: CGFloat = 10.0, duration: TimeInterval) {
        self.color = color
        self.unfilledColor = unfilledColor
        self.width = width
        self.duration = duration
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        unfilledRing.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        unfilledRing.path = UIBezierPath(roundedRect: bounds.insetBy(dx: -width, dy: -width), cornerRadius: bounds.size.width / 2).cgPath
        unfilledRing.position = bounds.center
        unfilledRing.bounds = bounds
        unfilledRing.cornerRadius = bounds.width / 2
    }
    
    private func setup() {
        isUserInteractionEnabled = false
        unfilledRing.lineWidth = width * 2
        unfilledRing.fillColor = nil
        unfilledRing.strokeColor = unfilledColor.cgColor
        unfilledRing.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func layout() {
        heightAnchor.equalTo(widthAnchor)
        layer.addSublayer(unfilledRing)
    }
    
    private func remainingDuration() -> TimeInterval {
        let currentTime = currentStrokeEnd() * duration
        return duration - currentTime
    }
    
    private func currentStrokeEnd() -> CGFloat {
        rings.last?.strokeEnd ?? 0.0
    }
    
    private func createRingSegment(duration: TimeInterval? = nil, fromValue: CGFloat? = nil, toValue: CGFloat? = nil) -> RingSegmentView {
        return RingSegmentView(color: color,
                        width: width,
                        duration: duration ?? remainingDuration(),
                        fromValue: fromValue ?? currentStrokeEnd(),
                        toValue: toValue ?? 1.0)
    }
    
    public func isAnimating() -> Bool {
        rings.any(matching: { $0.isAnimating })
    }
    
    public func startAnimation() {
        let ringSegment = createRingSegment()
        ringSegment.animationDelegate = self
        rings.append(ringSegment)
        ringSegment.embed(in: self)
        ringSegment.startAnimation()
        delegate?.viewDidStartAnimation(self)
    }
    
    public func stopAnimation() {
        if let ringSegment = rings.last {
            ringSegment.pauseAnimation()
        }
        delegate?.viewDidStopAnimation(self)
        let total = rings.map { ring -> TimeInterval in
            let d = ring.strokeEnd - ring.strokeFromValue
            return d * duration
        }.reduce(0) { $0 + $1 }
        isComplete = total == duration
    }
    
    public func addSegment(fromValue: CGFloat = 0.0, toValue: CGFloat = 1.0) {
        let dur = (toValue - fromValue) * duration
        let ringSegment = createRingSegment(duration: dur, fromValue: fromValue, toValue: toValue)
        ringSegment.animationDelegate = self
        rings.append(ringSegment)
        ringSegment.embed(in: self)
        CATransaction.withDisabledActions {
            ringSegment.setIsCompleted()
        }
    }
    
    public func removeSegment() {
        guard !isAnimating() else { return }
        guard !rings.isEmpty else { return }
        rings.removeLast().removeFromSuperview()
    }
    
    public func removeAllSegments() {
        rings.forEach { $0.removeFromSuperview() }
        rings.removeAll()
    }
}

extension RingView: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        guard flag else { return }
        stopAnimation()
    }
}

public final class RingSegmentView: UIView {
    public var color: UIColor {
        didSet { ring.strokeColor = color.cgColor }
    }
    public var width: CGFloat {
        didSet { ring.lineWidth = width; endMarker.lineWidth = width; setNeedsLayout() }
    }
    public var duration: TimeInterval {
        didSet { animation.duration = duration }
    }
    public var strokeFromValue: CGFloat {
        didSet { animation.fromValue = strokeFromValue }
    }
    public var strokeToValue: CGFloat {
        didSet { animation.toValue = strokeToValue }
    }
    public var strokeStart: CGFloat {
        ring.presentation()?.strokeStart ?? strokeFromValue
    }
    public var strokeEnd: CGFloat {
        ring.presentation()?.strokeEnd ?? strokeToValue
    }
    public var isAnimating: Bool {
        ring.speed == 1.0 && ring.animation(forKey: AnimationKeys.strokeEndAnimation) != nil
    }
    public var animationDelegate: CAAnimationDelegate? {
        get { animation.delegate }
        set { animation.delegate = newValue }
    }
    private let endMarker = CAShapeLayer()
    
    private struct AnimationKeys {
        static public let strokeEndAnimation = "strokeEndAnimation"
    }
    private lazy var ring = CAShapeLayer()
    private lazy var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = strokeFromValue
        animation.toValue = strokeToValue
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
        return animation
    }()
    
    public init(color: UIColor = UIColor.red.withAlphaComponent(0.7), width: CGFloat = 10.0, duration: TimeInterval = 5.0, fromValue: CGFloat = 0.0, toValue: CGFloat = 1.0) {
        self.color = color
        self.width = width
        self.duration = duration
        self.strokeFromValue = fromValue
        self.strokeToValue = toValue
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
        ring.position = bounds.center
        ring.bounds = .init(origin: bounds.origin, size: bounds.size)
        ring.path = UIBezierPath(roundedRect: ring.bounds.insetBy(dx: -width*1.5, dy: -width*1.5), cornerRadius: ring.bounds.size.width / 2).cgPath
        ring.cornerRadius = bounds.width / 2
        
        endMarker.position = bounds.center
        endMarker.bounds = bounds
        endMarker.path = UIBezierPath(roundedRect: bounds.insetBy(dx: -width*1.5, dy: -width*1.5), cornerRadius: bounds.size.width / 2).cgPath
        endMarker.cornerRadius = bounds.width / 2
    }
    
    private func setup() {
        endMarker.strokeStart = 0.0
        endMarker.strokeEnd = 0.0
        endMarker.lineWidth = width
        endMarker.fillColor = nil
        endMarker.strokeColor = UIColor.white.cgColor
        endMarker.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        endMarker.actions = ["strokeStart": NSNull(), "strokeEnd": NSNull()]
        ring.strokeStart = strokeFromValue
        ring.strokeEnd = strokeToValue
        ring.lineWidth = width
        ring.fillColor = UIColor.clear.cgColor
        ring.strokeColor = color.cgColor
        ring.anchorPoint = CGPoint(x: 0.5, y: 0.5)
    }
    
    private func layout() {
        heightAnchor.equalTo(widthAnchor)
        layer.addSublayer(ring)
        layer.addSublayer(endMarker)
    }

    public func startAnimation() {
        if let animationKeys = ring.animationKeys(), animationKeys.contains(AnimationKeys.strokeEndAnimation) {
            let pausedTime = ring.timeOffset
            ring.speed = 1.0
            ring.timeOffset = 0.0
            ring.beginTime = 0.0
            let timeSincePause = ring.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
            ring.beginTime = timeSincePause
        } else {
            ring.add(animation, forKey: AnimationKeys.strokeEndAnimation)
        }
    }
        
    public func pauseAnimation() {
        let pausedTime = ring.convertTime(CACurrentMediaTime(), from: nil)
        ring.speed = 0.0
        ring.timeOffset = pausedTime
        setIsCompleted()
    }
    
    public func resetAnimation() {
        ring.removeAnimation(forKey: AnimationKeys.strokeEndAnimation)
    }
    
    public func setIsCompleted() {
        endMarker.strokeStart = strokeEnd - 0.01
        endMarker.strokeEnd = strokeEnd
    }
}

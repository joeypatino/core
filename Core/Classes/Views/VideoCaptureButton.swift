import UIKit

public protocol VideoCaptureButtonDelegate: AnyObject {
    func view(_ viewController: VideoCaptureButton, failedWithError error: Error)
}

public class VideoCaptureButton: UIButton {
    public weak var delegate: VideoCaptureButtonDelegate?
    private struct AnimationKeys {
        static public let strokeEndAnimation = "strokeEndAnimation"
    }
    public enum Error: Swift.Error, LocalizedError {
        case isComplete
        public var errorDescription: String? { "You've reached the maximum recording time limit." }
    }
    public var duration: TimeInterval {
        didSet { animation.duration = duration }
    }
    public var isAnimating = false
    
    public var strokeStart: CGFloat {
        get { fill.presentation()?.strokeStart ?? fill.model().strokeStart }
        set {
            fill.strokeStart = newValue
            fillMaskRing.strokeStart = newValue
            fillMask.mask = invertMaskLayer(fillMaskRing)
        }
    }
    
    public var strokeEnd: CGFloat {
        get { fill.presentation()?.strokeEnd ?? fill.model().strokeEnd }
        set {
            fill.strokeEnd = newValue
            fillMaskRing.strokeEnd = newValue
            fillMask.mask = invertMaskLayer(fillMaskRing)
        }
    }
    public var isComplete: Bool {
        strokeEnd >= 1.0
    }
    
    public var animationDelegate: CAAnimationDelegate? {
        get { animation.delegate }
        set { animation.delegate = newValue }
    }
    public var strokeColor: UIColor = .green {
        didSet { update() }
    }
    private let background = CAShapeLayer()
    private let fillMaskRing = CAShapeLayer()
    private let fixed = CAShapeLayer()
    private let fillMask = CAShapeLayer()
    private var fill = CAShapeLayer()
    private let inner = CAShapeLayer()
    private let animatingRingWidth: CGFloat = 4
    private let normalRingWidth: CGFloat = 3
    private let gutter: CGFloat = 2
    private var stopInset: CGFloat { normalRingWidth + gutter + 16 }
    private var timePoints: [CGFloat] = []
    private var lineDashPoints: [CGFloat] = [] {
        didSet {
            fixed.lineDashPattern = lineDashPoints.map { NSNumber(value: $0) }
            fillMask.lineDashPattern = lineDashPoints.map { NSNumber(value: $0) }
            fillMask.mask = invertMaskLayer(fillMaskRing)
        }
    }
    private var animationTimer: Timer?
    
    private lazy var animation: CABasicAnimation = {
        let animation = CABasicAnimation(keyPath: "strokeEnd")
        animation.fromValue = 0
        animation.toValue = 1.0
        animation.duration = duration
        animation.fillMode = .forwards
        animation.isRemovedOnCompletion = false
        animation.delegate = self
        animation.timingFunction = CAMediaTimingFunction(name: .linear)
        return animation
    }()
    
    public init(duration: TimeInterval = 5) {
        self.duration = duration
        super.init(frame: .zero)
        animation.duration = duration
        setup()
        layout()
        update()
        clear()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func performLayoutSubviews() {
        background.position = bounds.center
        background.bounds = bounds
        background.cornerRadius = bounds.width/2
        background.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
        
        inner.position = bounds.center
        inner.bounds = bounds
        inner.cornerRadius = bounds.width/2
        
        inner.add(animation("path", duration: 0.2), forKey: nil)
        inner.path = isAnimating
        ? UIBezierPath(roundedRect: bounds.insetBy(dx: stopInset, dy: stopInset), cornerRadius: 4).cgPath
        : UIBezierPath(roundedRect: bounds.insetBy(dx: normalRingWidth + gutter, dy: normalRingWidth + gutter), cornerRadius: bounds.width/2).cgPath
        
        fixed.position = bounds.center
        fixed.bounds = bounds
        fixed.cornerRadius = bounds.width/2
        fixed.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
        
        fill.position = bounds.center
        fill.bounds = bounds
        fill.cornerRadius = bounds.width/2
        
        fill.add(animation("path", duration: 0.2), forKey: nil)
        fill.path = isAnimating
        ? UIBezierPath(roundedRect: bounds.insetBy(dx: normalRingWidth+1.5, dy: normalRingWidth+1.5), cornerRadius: bounds.width/2).cgPath
        : UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath

        fillMaskRing.position = bounds.center
        fillMaskRing.bounds = bounds
        fillMaskRing.cornerRadius = bounds.width/2
        fillMaskRing.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
        fillMaskRing.lineWidth = normalRingWidth

        fillMask.position = bounds.center
        fillMask.bounds = bounds
        fillMask.cornerRadius = bounds.width/2
        fillMask.path = UIBezierPath(roundedRect: bounds, cornerRadius: bounds.width/2).cgPath
        fillMask.mask = invertMaskLayer(fillMaskRing)

        fixed.add(animation("lineWidth", duration: 0.2), forKey: nil)
        fixed.lineWidth = isAnimating ? animatingRingWidth + gutter : normalRingWidth
        
        fixed.add(animation("opacity", duration: 0.2), forKey: nil)
        fixed.opacity = isAnimating ? 0 : 1

        fill.add(animation("lineWidth", duration: 0.2), forKey: nil)
        fill.lineWidth = isAnimating ? animatingRingWidth + gutter : normalRingWidth

        fill.add(animation("lineCap", duration: 0.2), forKey: nil)
        fill.lineCap = isAnimating ? .round : .square

        background.add(animation("opacity", duration: 0.2), forKey: nil)
        background.opacity = isAnimating ? 1 : 0
    }

    public override func layoutSubviews() {
        super.layoutSubviews()
        guard !bounds.isEmpty else {
            return
        }
        performLayoutSubviews()
    }
    
    private func invertMaskLayer(_ maskLayer: CALayer) -> CALayer {
        let largeOpaqueLayer = CALayer()
        largeOpaqueLayer.bounds = maskLayer.bounds
        largeOpaqueLayer.backgroundColor = UIColor.black.cgColor
        largeOpaqueLayer.addSublayer(maskLayer)
        maskLayer.compositingFilter = "xor"
        return largeOpaqueLayer
    }

    @objc private func onGesture(_ gesture: UITapGestureRecognizer) {
        sendActions(for: .touchUpInside)
    }

    private var isCompletedError = false
    @objc private func onLongPressGesture(_ gesture: UITapGestureRecognizer) {
        switch gesture.state {
        case .began:
            isCompletedError = false
            do {
                try startAnimation()
            } catch {
                isCompletedError = true
                let animations = { self.transform = .init(scaleX: 0.9, y: 0.9) }
                UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: animations)
                delegate?.view(self, failedWithError: error)
            }
        case .cancelled, .failed, .ended:
            if !isCompletedError && !isComplete {
                stopAnimation()
            }
            let animations = { self.transform = .identity }
            UIView.animate(withDuration: 0.15, delay: 0, options: .curveEaseInOut, animations: animations)
        default:
            break
        }
    }
    
    // MARK: - Private
    
    private func setup() {
        background.fillColor = UIColor.white.withAlphaComponent(0.35).cgColor
        inner.fillColor = UIColor.white.cgColor
        
        fixed.fillColor = UIColor.clear.cgColor
        fixed.strokeColor = UIColor.white.cgColor
        fixed.lineWidth = normalRingWidth
        
        fill.fillColor = UIColor.clear.cgColor
        fill.strokeColor = strokeColor.cgColor
        fill.lineWidth = normalRingWidth
        fill.lineCap = .round
        
        // masks the fill ring mask, based on start / end stroke... only masks the normal button state ring...
        fillMaskRing.fillColor = UIColor.clear.cgColor
        fillMaskRing.strokeColor = UIColor.white.cgColor
        fillMaskRing.lineWidth = normalRingWidth
        
        fillMask.fillColor = UIColor.clear.cgColor
        fillMask.strokeColor = UIColor.black.cgColor
        fillMask.lineWidth = normalRingWidth
        
        fill.speed = 0.0
        fill.add(animation, forKey: AnimationKeys.strokeEndAnimation)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(onLongPressGesture(_:)))
        addGestureRecognizer(longPressGesture)
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onGesture(_:)))
        tapGesture.require(toFail: longPressGesture)
        addGestureRecognizer(tapGesture)
    }
    
    private func layout() {
        heightAnchor.equalTo(widthAnchor)
        layer.addSublayer(background)
        layer.addSublayer(inner)
        layer.addSublayer(fixed)
        layer.addSublayer(fill)
    }
    
    private func update() {
        fill.strokeColor = strokeColor.cgColor
        fillMaskRing.strokeColor = strokeColor.cgColor
    }
    
    // MARK: - Public
    
    public func addTime(_ fromValue: CGFloat = 0.0, toValue: CGFloat = 1.0, adjustStrokeEnd: Bool = true) {
        strokeEnd = toValue
        _addLineDash(to: toValue, isClosed: strokeEnd == 1.0)
        
        if adjustStrokeEnd {
            // STOP
            let pausedTime = fill.convertTime(CACurrentMediaTime(), from: nil)
            fill.speed = 0.0
            fill.timeOffset = pausedTime
            fill.beginTime = (toValue - fromValue) * self.duration

            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            fill.add(animation("mask", duration: 0), forKey: nil)
            fill.mask = nil
            background.add(animation("transform", duration: 0.2), forKey: "transforming")
            background.transform = CATransform3DMakeScale(1.3, 1.3, 1)
            fixed.add(animation("transform", duration: 0.2), forKey: nil)
            fixed.transform = CATransform3DMakeScale(1.3, 1.3, 1)
            fill.add(animation("transform", duration: 0.2), forKey: nil)
            fill.transform = CATransform3DMakeScale(1.3, 1.3, 1)
            CATransaction.commit()

            CATransaction.begin()
            CATransaction.setAnimationDuration(0)
            CATransaction.setDisableActions(true)
            CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))
            fill.add(animation("mask", duration: 0), forKey: nil)
            fill.mask = fillMask
            
            background.add(animation("transform", duration: 0.2), forKey: "untransforming")
            background.transform = CATransform3DIdentity
            fixed.add(animation("transform", duration: 0.2), forKey: nil)
            fixed.transform = CATransform3DIdentity
            fill.add(animation("transform", duration: 0.2), forKey: nil)
            fill.transform = CATransform3DIdentity
            performLayoutSubviews()
            CATransaction.commit()
        }
    }

    public func startAnimation(animated: Bool = true, shouldSendActions: Bool = true) throws {
        guard !isComplete else { throw Error.isComplete }
        guard background.animation(forKey: "untransforming") == nil else { return }
        if isAnimating { return }
        isAnimating = !isAnimating
        
        animationTimer?.invalidate()
        animationTimer = Timer.scheduledTimer(timeInterval: 1.0/30.0, target: self, selector: #selector(onAnimationUpdate(_:)), userInfo: nil, repeats: true)

        /// FORCE REFRESH
        let pausedTime = fill.timeOffset + fill.beginTime
        
        // resume animation from paused state
        fill.speed = 1.0
        fill.timeOffset = 0.0
        fill.beginTime = 0.0
        let timeSincePause = fill.convertTime(CACurrentMediaTime(), from: nil) - pausedTime
        fill.beginTime = timeSincePause
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.2 : 0)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        fill.add(animation("mask", duration: 0.2), forKey: nil)
        fill.mask = nil
        
        background.add(animation("transform", duration: animated ? 0.2 : 0), forKey: "transforming")
        background.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        fixed.add(animation("transform", duration: animated ? 0.2 : 0), forKey: nil)
        fixed.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        fill.add(animation("transform", duration: animated ? 0.2 : 0), forKey: nil)
        fill.transform = CATransform3DMakeScale(1.3, 1.3, 1)
        
        performLayoutSubviews()
        if shouldSendActions { self.sendActions(for: .editingDidBegin) }
        CATransaction.commit()
    }
    
    public func stopAnimation(animated: Bool = true, shouldSendActions: Bool = true) {
        isAnimating = false
        animationTimer?.invalidate()
        
        // pause the stroke animation
        let pausedTime = fill.convertTime(CACurrentMediaTime(), from: nil)
        fill.speed = 0.0
        fill.beginTime = 0.0
        fill.timeOffset = pausedTime
        //print("[PausedTime] ", pausedTime)

        if shouldSendActions {
            sendActions(for: .editingDidEnd)
        }
        
        fill.add(animation("mask", duration: animated ? 0.2 : 0), forKey: nil)
        fill.mask = fillMask
        
        CATransaction.begin()
        CATransaction.setAnimationDuration(animated ? 0.2 : 0)
        CATransaction.setAnimationTimingFunction(CAMediaTimingFunction(name: .easeInEaseOut))

        background.add(animation("transform", duration: animated ? 0.2 : 0, delay: 0.1), forKey: "untransforming")
        background.transform = CATransform3DIdentity
        fixed.add(animation("transform", duration: animated ? 0.2 : 0, delay: 0.1), forKey: nil)
        fixed.transform = CATransform3DIdentity
        fill.add(animation("transform", duration: animated ? 0.2 : 0, delay: 0.1), forKey: nil)
        fill.transform = CATransform3DIdentity

        performLayoutSubviews()
        DispatchQueue.main.asyncAfter(delay: animated ? 0.2 : 0) {
            if self.strokeEnd == 1.0 && shouldSendActions {
                self.sendActions(for: .editingDidEnd)
            }
        }
        CATransaction.commit()
    }

    public func clear() {
        timePoints.removeAll()
        lineDashPoints.removeAll()
        strokeEnd = 0
        strokeStart = 0
        stop()
    }
    
    private func stop() {
        isAnimating = false
        background.removeAllAnimations()
        background.transform = CATransform3DIdentity
        fixed.removeAllAnimations()
        fixed.transform = CATransform3DIdentity
        //fill.removeAllAnimations()
        fill.animationKeys()?.filter({ $0 != AnimationKeys.strokeEndAnimation }).forEach( { fill.removeAnimation(forKey: $0 )})
        fill.transform = CATransform3DIdentity
        performLayoutSubviews()
        //fill.removeAllAnimations()
        fill.animationKeys()?.filter({ $0 != AnimationKeys.strokeEndAnimation }).forEach( { fill.removeAnimation(forKey: $0 )})
        fill.mask = fillMask
        let pausedTime = fill.convertTime(CACurrentMediaTime(), from: nil)
        fill.speed = 0.0
        fill.timeOffset = pausedTime
    }
    
    // MARK: - Helper
    
    private func _addLineDash(to: CGFloat, isClosed: Bool = false) {
        let needsFiller = lineDashPoints.count == 0
        if needsFiller {
            let a = 0.0 * (CGFloat.pi/180) * (bounds.width/2)
            lineDashPoints.append(a)
            lineDashPoints.append(a + 2)
        }
        // remove last two points, since they are fillers
        if lineDashPoints.count > 1 && !needsFiller {
            _ = lineDashPoints.remove(at: lineDashPoints.count-1)
            _ = lineDashPoints.remove(at: lineDashPoints.count-1)
        }
        timePoints.append(to)
        let p1: CGFloat
        let p2: CGFloat
        if timePoints.count == 1 {
            p1 = 0
            p2 = to
        } else {
            p1 = timePoints[timePoints.count-2]
            p2 = timePoints[timePoints.count-1]
        }
        // calculate angle between p1 and p2
        // given a circle with radius of bounds.width/2
        let p1a = p1 * 360.0
        let p2a = p2 * 360.0
        // Length of an Arc = θ × (π/180) × r, where θ is in degree.
        let len = (p2a - p1a) * (CGFloat.pi/180) * (bounds.width/2)
        lineDashPoints.append(CGFloat(len)-2)
        lineDashPoints.append(2)
        
        guard !isClosed else { return }
        let px: CGFloat = 1.0
        let pxa = px * 360
        let xlen = (p1a - pxa) * (CGFloat.pi/180) * (bounds.width/2)
        lineDashPoints.append(CGFloat(xlen)-2)
        lineDashPoints.append(2)
    }
    
    private func addLineDash(isClosed: Bool = false) {
        let needsFiller = lineDashPoints.count == 0
        if needsFiller {
            let a = 0.0 * (CGFloat.pi/180) * (bounds.width/2)
            lineDashPoints.append(a)
            lineDashPoints.append(a + 2)
        }
        // remove last two points, since they are fillers
        if lineDashPoints.count > 1 && !needsFiller {
            _ = lineDashPoints.remove(at: lineDashPoints.count-1)
            _ = lineDashPoints.remove(at: lineDashPoints.count-1)
        }
        timePoints.append(strokeEnd)
        let p1: CGFloat
        let p2: CGFloat
        if timePoints.count == 1 {
            p1 = 0
            p2 = strokeEnd
        } else {
            p1 = timePoints[timePoints.count-2]
            p2 = timePoints[timePoints.count-1]
        }
        // calculate angle between p1 and p2
        // given a circle with radius of bounds.width/2
        let p1a = p1 * 360.0
        let p2a = p2 * 360.0
        // Length of an Arc = θ × (π/180) × r, where θ is in degree.
        let len = (p2a - p1a) * (CGFloat.pi/180) * (bounds.width/2)
        lineDashPoints.append(CGFloat(len)-2)
        lineDashPoints.append(2)
        
        guard !isClosed else { return }
        let px: CGFloat = 1.0
        let pxa = px * 360
        let xlen = (p1a - pxa) * (CGFloat.pi/180) * (bounds.width/2)
        lineDashPoints.append(CGFloat(xlen)-2)
        lineDashPoints.append(2)
    }
    
    private func animation(_ keyPath: String, duration: TimeInterval, delay: TimeInterval = 0, fillMode: CAMediaTimingFillMode = .removed) -> CABasicAnimation {
        let animation = CABasicAnimation(keyPath: keyPath)
        animation.duration = duration
        animation.fillMode = fillMode
        animation.beginTime = delay
        return animation
    }
    
    @objc private func onAnimationUpdate(_ sender: Timer) {
        stopIfComplete()
    }
    
    private func stopIfComplete() {
        if isComplete {
            stopAnimation()
            animationTimer?.invalidate()
        }
    }
}

extension VideoCaptureButton: CAAnimationDelegate {
    public func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
        animationTimer?.invalidate()
        guard flag else { return }
        stopAnimation()
    }
}

//
//  PryntTrimmerView.swift
//  PryntTrimmerView
//
//  Created by HHK on 27/03/2017.
//  Copyright © 2017 Prynt. All rights reserved.
//

import AVFoundation
import UIKit
import Core

/// A view to select a specific time range of a video. It consists of an asset preview with thumbnails inside a scroll view, two
/// handles on the side to select the beginning and the end of the range, and a position bar to synchronize the control with a
/// video preview, typically with an `AVPlayer`.
/// Load the video by setting the `asset` property. Access the `startTime` and `endTime` of the view to get the selected time
// range
@IBDesignable public class TrimmerView: AVAssetTimeSelector {
    public enum Event {
        case didBeginTrimming
        case selectedRangeChanged
        case didEndTrimming
        case didBeginScrubbing
        case progressChanged
        case didEndScrubbing
    }
    
    // events for changing selectedRange ("trimming")
    static let didBeginTrimming = UIControl.Event(rawValue:     0b00000001 << 24)
    static let selectedRangeChanged = UIControl.Event(rawValue: 0b00000010 << 24)
    static let didEndTrimming = UIControl.Event(rawValue:       0b00000100 << 24)
    
    // events for scrubbing the progress indicator ("scrubbing")
    static let didBeginScrubbing = UIControl.Event(rawValue:    0b00001000 << 24)
    static let progressChanged = UIControl.Event(rawValue:      0b00010000 << 24)
    static let didEndScrubbing = UIControl.Event(rawValue:      0b00100000 << 24)

    
    // MARK: - Properties

    // MARK: Color Customization

    /// The color of the main border of the view
    @IBInspectable public var mainColor: UIColor = UIColor.orange {
        didSet {
            updateMainColor()
        }
    }

    /// The color of the handles on the side of the view
    @IBInspectable public var handleColor: UIColor = UIColor.gray {
        didSet {
           updateHandleColor()
        }
    }

    /// The color of the handles inset on the side of the view
    @IBInspectable public var handleInsetColor: UIColor = UIColor.red {
        didSet {
           updateHandleInsetColor()
        }
    }

    /// The color of the position indicator
    @IBInspectable public var positionBarColor: UIColor = UIColor.white {
        didSet {
            positionBar.backgroundColor = positionBarColor
        }
    }

    /// The color used to mask unselected parts of the video
    @IBInspectable public var maskColor: UIColor = UIColor.white {
        didSet {
            leftMaskView.backgroundColor = maskColor
            rightMaskView.backgroundColor = maskColor
        }
    }

    /// The color used for the borders around the trimmer
    @IBInspectable public var borderColor: UIColor = UIColor.white {
        didSet {
            topView.backgroundColor = borderColor
            bottomView.backgroundColor = borderColor
            leftHandleView.color = borderColor
            rightHandleView.color = borderColor
        }
    }
    
    /// the width of the top and bottom borders. should be 4 to match the left and right border sizes?
    @IBInspectable public var borderWidth: CGFloat = 4 {
        didSet {
            topViewHeightConstraint.constant = borderWidth
            bottomViewHeightConstraint.constant = borderWidth
        }
    }

    ///
    @IBInspectable public var horizontalInset: CGFloat = 8 {
        didSet {
            
        }
    }

    // MARK: Subviews

    private let trimView = UIView()
    private let leftHandleView = LeftHandlerView()
    private let rightHandleView = RightHandlerView()
    private let leftHandleInsetView = UIView()
    private let rightHandleInsetView = UIView()
    
    private let topView = UIView()
    private let bottomView = UIView()
    
    private let positionBar = PositionBar()
    private let leftHandleKnob = UIView()
    private let rightHandleKnob = UIView()
    private let leftMaskView = UIView()
    private let rightMaskView = UIView()

    // MARK: Constraints

    private lazy var currentLeftConstraint: CGFloat = horizontalInset
    private lazy var currentRightConstraint: CGFloat = -horizontalInset
    private var leftConstraint: NSLayoutConstraint?
    private var rightConstraint: NSLayoutConstraint?
    private var positionConstraint: NSLayoutConstraint?
    private var topViewHeightConstraint = NSLayoutConstraint()
    private var bottomViewHeightConstraint = NSLayoutConstraint()
    
    private let handleWidth: CGFloat = 10

    /// The minimum duration allowed for the trimming. The handles won't pan further if the minimum duration is attained.
    public var minDuration: Double = 1

    // MARK: - View & constraints configurations
    
    override func setupSubviews() {
        super.setupSubviews()
        backgroundColor = .clear
        layer.zPosition = 1
        setupTrimmerView()
        setupHandleView()
        setupMaskView()
        setupPositionBar()
        setupGestures()
        updateMainColor()
        updateHandleColor()
        updateHandleInsetColor()
    }

    override func constrainAssetPreview() {
        assetPreview.leftAnchor.constraint(equalTo: leftAnchor, constant: handleWidth).isActive = true
        assetPreview.rightAnchor.constraint(equalTo: rightAnchor, constant: -handleWidth).isActive = true
        assetPreview.topAnchor.constraint(equalTo: topAnchor).isActive = true
        assetPreview.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
    }

    private func setupTrimmerView() {
        trimView.translatesAutoresizingMaskIntoConstraints = false
        trimView.isUserInteractionEnabled = false
        addSubview(trimView)

        trimView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        trimView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftConstraint = trimView.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalInset)
        rightConstraint = trimView.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalInset)
        leftConstraint?.isActive = true
        rightConstraint?.isActive = true
    }

    private func setupHandleView() {
        leftHandleView.isUserInteractionEnabled = true
        leftHandleKnob.layer.cornerRadius = 4.0
        leftHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(leftHandleView)

        leftHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        leftHandleView.leftAnchor.constraint(equalTo: trimView.leftAnchor).isActive = true
        leftHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        leftHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        leftHandleView.addSubview(leftHandleKnob)

        leftHandleKnob.heightAnchor.constraint(equalToConstant: 30).isActive = true
        leftHandleKnob.widthAnchor.constraint(equalToConstant: 14).isActive = true
        leftHandleKnob.centerYAnchor.constraint(equalTo: leftHandleView.centerYAnchor).isActive = true
        leftHandleKnob.centerXAnchor.constraint(equalTo: leftHandleView.centerXAnchor, constant: -4).isActive = true

        rightHandleView.isUserInteractionEnabled = true
        rightHandleKnob.layer.cornerRadius = 4.0
        rightHandleView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(rightHandleView)

        rightHandleView.heightAnchor.constraint(equalTo: heightAnchor).isActive = true
        rightHandleView.rightAnchor.constraint(equalTo: trimView.rightAnchor).isActive = true
        rightHandleView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true

        rightHandleKnob.translatesAutoresizingMaskIntoConstraints = false
        rightHandleView.addSubview(rightHandleKnob)

        rightHandleKnob.heightAnchor.constraint(equalToConstant: 30).isActive = true
        rightHandleKnob.widthAnchor.constraint(equalToConstant: 14).isActive = true
        rightHandleKnob.centerYAnchor.constraint(equalTo: rightHandleView.centerYAnchor).isActive = true
        rightHandleKnob.centerXAnchor.constraint(equalTo: rightHandleView.centerXAnchor, constant: 4).isActive = true
        
        leftHandleInsetView.translatesAutoresizingMaskIntoConstraints = false
        leftHandleKnob.addSubview(leftHandleInsetView)
        leftHandleInsetView.widthAnchor.constraint(equalToConstant: 4).isActive = true
        leftHandleInsetView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        leftHandleInsetView.centerYAnchor.constraint(equalTo: leftHandleKnob.centerYAnchor).isActive = true
        leftHandleInsetView.centerXAnchor.constraint(equalTo: leftHandleKnob.centerXAnchor).isActive = true
        leftHandleInsetView.layer.cornerRadius = 4.0
    
        rightHandleInsetView.translatesAutoresizingMaskIntoConstraints = false
        rightHandleKnob.addSubview(rightHandleInsetView)
        rightHandleInsetView.widthAnchor.constraint(equalToConstant: 4).isActive = true
        rightHandleInsetView.heightAnchor.constraint(equalToConstant: 16).isActive = true
        rightHandleInsetView.centerYAnchor.constraint(equalTo: rightHandleKnob.centerYAnchor).isActive = true
        rightHandleInsetView.centerXAnchor.constraint(equalTo: rightHandleKnob.centerXAnchor).isActive = true
        rightHandleInsetView.layer.cornerRadius = 4.0

        topView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(topView)
        topView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        topViewHeightConstraint = topView.heightAnchor.constraint(equalToConstant: borderWidth)
        topViewHeightConstraint.isActive = true
        topView.leadingAnchor.constraint(equalTo: leftHandleKnob.trailingAnchor).isActive = true
        topView.trailingAnchor.constraint(equalTo: rightHandleKnob.leadingAnchor).isActive = true

        bottomView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(bottomView)
        bottomView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        bottomViewHeightConstraint = bottomView.heightAnchor.constraint(equalToConstant: borderWidth)
        bottomViewHeightConstraint.isActive = true
        bottomView.leadingAnchor.constraint(equalTo: leftHandleKnob.trailingAnchor).isActive = true
        bottomView.trailingAnchor.constraint(equalTo: rightHandleKnob.leadingAnchor).isActive = true
    }

    private func setupMaskView() {

        leftMaskView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMinXMaxYCorner]
        leftMaskView.layer.cornerRadius = 4
        leftMaskView.isUserInteractionEnabled = false
        leftMaskView.backgroundColor = .black
        leftMaskView.alpha = 0.6
        leftMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(leftMaskView, belowSubview: leftHandleView)

        leftMaskView.leftAnchor.constraint(equalTo: leftAnchor, constant: horizontalInset).isActive = true
        leftMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        leftMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        leftMaskView.rightAnchor.constraint(equalTo: leftHandleView.centerXAnchor).isActive = true

        rightMaskView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMaxXMaxYCorner]
        rightMaskView.layer.cornerRadius = 4
        rightMaskView.isUserInteractionEnabled = false
        rightMaskView.backgroundColor = .black
        rightMaskView.alpha = 0.6
        rightMaskView.translatesAutoresizingMaskIntoConstraints = false
        insertSubview(rightMaskView, belowSubview: rightHandleView)

        rightMaskView.rightAnchor.constraint(equalTo: rightAnchor, constant: -horizontalInset).isActive = true
        rightMaskView.bottomAnchor.constraint(equalTo: bottomAnchor).isActive = true
        rightMaskView.topAnchor.constraint(equalTo: topAnchor).isActive = true
        rightMaskView.leftAnchor.constraint(equalTo: rightHandleView.centerXAnchor).isActive = true
    }

    private func setupPositionBar() {
        positionBar.frame = CGRect(x: 0, y: 0, width: 3, height: frame.height)
        positionBar.backgroundColor = positionBarColor
        positionBar.center = CGPoint(x: leftHandleView.frame.maxX, y: center.y)
        positionBar.layer.cornerRadius = 1
        positionBar.translatesAutoresizingMaskIntoConstraints = false
        positionBar.isUserInteractionEnabled = false
        addSubview(positionBar)

        positionBar.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        positionBar.widthAnchor.constraint(equalToConstant: 3).isActive = true
        positionBar.heightAnchor.constraint(equalTo: heightAnchor, constant: 16).isActive = true
        positionConstraint = positionBar.leftAnchor.constraint(equalTo: leftHandleView.rightAnchor, constant: 0)
        positionConstraint?.isActive = true
    }

    private func setupGestures() {

        let leftPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture(_:)))
        leftHandleView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(TrimmerView.handlePanGesture(_:)))
        rightHandleView.addGestureRecognizer(rightPanGestureRecognizer)
        
        let progressGestureRecognizer = UILongPressGestureRecognizer(target: self, action: #selector(TrimmerView.progressGrabberPanned(_:)))
        progressGestureRecognizer.allowableMovement = CGFloat.greatestFiniteMagnitude
        progressGestureRecognizer.minimumPressDuration = 0
        progressGestureRecognizer.require(toFail: leftPanGestureRecognizer)
        progressGestureRecognizer.require(toFail: rightPanGestureRecognizer)
        positionBar.addGestureRecognizer(progressGestureRecognizer)
    }

    private func updateMainColor() {
        trimView.layer.borderColor = mainColor.cgColor
    }

    private func updateHandleColor() {
        leftHandleKnob.backgroundColor = handleColor
        rightHandleKnob.backgroundColor = handleColor
    }
    
    private func updateHandleInsetColor() {
        rightHandleInsetView.backgroundColor = handleInsetColor
        leftHandleInsetView.backgroundColor = handleInsetColor
    }

    // MARK: - Trim Gestures

    // defines if the user is trimming or not, and if so, which edge
    enum TrimmingState {
        case none        // user isn't trimming
        case leading    // user is trimming the leading part of the asset
        case trailing    // user is trimming the trailing part of the asset
    }
    
    private(set) var trimmingState = TrimmingState.none
    private var isScrubbing: Bool = false
    private var impactFeedbackGenerator: UIImpactFeedbackGenerator?
    
    @objc private func handlePanGesture(_ gestureRecognizer: UIPanGestureRecognizer) {
        guard let view = gestureRecognizer.view, let superView = gestureRecognizer.view?.superview else { return }
        let isLeftGesture = view == leftHandleView
        switch gestureRecognizer.state {

        case .began:
            if isLeftGesture {
                currentLeftConstraint = leftConstraint!.constant
            } else {
                currentRightConstraint = rightConstraint!.constant
            }
        case .changed:
            let translation = gestureRecognizer.translation(in: superView)
            if isLeftGesture {
                updateLeftConstraint(with: translation)
            } else {
                updateRightConstraint(with: translation)
            }
            sendActions(for: Self.selectedRangeChanged)
            layoutIfNeeded()
            if let startTime = startTime, isLeftGesture {
                seek(to: startTime)
            } else if let endTime = endTime {
                seek(to: endTime)
            }
        case .cancelled, .ended, .failed:
            break
        default: break
        }
    }

    @objc private func progressGrabberPanned(_ sender: UILongPressGestureRecognizer) {
        func handleChanged() {
            let location = sender.location(in: self)
            //guard var time = getTime(from: location.x - horizontalInset - handleWidth) else { return }
            guard var time = getTime(from: location.x) else { return }
            
            if CMTimeCompare(time, selectedRange.start) == -1 {
                time = selectedRange.start
            }
            if CMTimeCompare(time, selectedRange.end) == 1 {
                time = selectedRange.end
            }
            progress = time
//            setNeedsLayout()
//            sendActions(for: Self.progressChanged)
            if let position = getPosition(from: time) {
                positionConstraint?.constant = position - horizontalInset
                setNeedsLayout()
                sendActions(for: Self.progressChanged)
            }
        }
        switch sender.state {
        case .began:
            isScrubbing = true
            sendActions(for: Self.didBeginScrubbing)
            handleChanged()
        case .changed:
            handleChanged()
        case .ended, .cancelled:
            isScrubbing = false
            sendActions(for: Self.didEndScrubbing)
        case .possible, .failed:
            break

        @unknown default:
            break
        }
    }

    private func updateLeftConstraint(with translation: CGPoint) {
        let maxConstraint = max(rightHandleView.frame.origin.x - handleWidth - minimumDistanceBetweenHandle - horizontalInset, 0)
        let newConstraint = min(max(horizontalInset, currentLeftConstraint + translation.x), maxConstraint)
        leftConstraint?.constant = newConstraint
    }

    private func updateRightConstraint(with translation: CGPoint) {
        let maxConstraint = min(2 * handleWidth - frame.width + leftHandleView.frame.origin.x + minimumDistanceBetweenHandle, 0)
        let newConstraint = max(min(-horizontalInset, currentRightConstraint + translation.x), maxConstraint)
        rightConstraint?.constant = newConstraint
    }

    private func startPanning() {
        sendActions(for: Self.didBeginTrimming)
        UISelectionFeedbackGenerator().selectionChanged()
        
        impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedbackGenerator?.prepare()
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.updateProgressIndicator()
        })
    }
    
    private func stopPanning() {
        trimmingState = .none
        impactFeedbackGenerator = nil
        sendActions(for: Self.didEndTrimming)
        
        UIView.animate(withDuration: 0.25, delay: 0, options: [.beginFromCurrentState, .allowUserInteraction], animations: {
            self.updateProgressIndicator()
        })
    }
    
    // defines what to do with the progress indicator
    public enum ProgressIndicatorMode {
        case hiddenOnlyWhenTrimming // the progress indicator gets hidden when the user starts trimming
        case alwaysShown // the progress indicator is always shown, even when the user is trimming
        case alwaysHidden // the progress indicator is never shown
    }
    public var progressIndicatorMode = ProgressIndicatorMode.hiddenOnlyWhenTrimming {
        didSet {
            updateProgressIndicator()
        }
    }

    private func updateProgressIndicator() {
        switch progressIndicatorMode {
        case .alwaysHidden:
            positionBar.alpha = 0
            positionBar.isUserInteractionEnabled = false
        case .alwaysShown:
            positionBar.alpha = 1
            positionBar.isUserInteractionEnabled = true
            setNeedsLayout()
            
        case .hiddenOnlyWhenTrimming:
            positionBar.alpha = (trimmingState == .none ? 1 : 0)
            positionBar.isUserInteractionEnabled = (trimmingState == .none)
            if trimmingState == .none {
                setNeedsLayout()
                if UIView.inheritedAnimationDuration > 0 {
                    UIView.performWithoutAnimation {
                        layoutIfNeeded()
                    }
                }
            }
        }
        positionBar.alpha = positionBar.alpha
    }
    
    // MARK: - Asset loading

    override func assetDidChange(newAsset: AVAsset?) {
        super.assetDidChange(newAsset: newAsset)
        resetHandleViewPosition()
    }

    private func resetHandleViewPosition() {
        leftConstraint?.constant = horizontalInset
        rightConstraint?.constant = -horizontalInset
        layoutIfNeeded()
    }

    // MARK: - Time Equivalence

    /// Move the position bar to the given time.
    public func seek(to time: CMTime) {
        guard !isScrubbing else { return }
        if let newPosition = getPosition(from: time) {

            let offsetPosition = newPosition - assetPreview.contentOffset.x - leftHandleView.frame.origin.x
            let maxPosition = rightHandleView.frame.origin.x - (leftHandleView.frame.origin.x + handleWidth)
                              - positionBar.frame.width
            let normalizedPosition = min(max(0, offsetPosition), maxPosition)
            positionConstraint?.constant = normalizedPosition
            layoutIfNeeded()
        }
    }

    /// The selected start time for the current asset.
    public var startTime: CMTime? {
        let startPosition = leftHandleView.frame.origin.x + assetPreview.contentOffset.x
        return getTime(from: startPosition)
    }

    /// The selected end time for the current asset.
    public var endTime: CMTime? {
        let endPosition = rightHandleView.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        return getTime(from: endPosition)
    }

    public var selectedRange: CMTimeRange {
        get { CMTimeRange(start: startTime ?? .zero, end: endTime ?? .zero) }
        set {
            if let leading = getPosition(from: newValue.start) {
                leftConstraint?.constant = leading
                updateLeftConstraint(with: .zero)
            }
            if let trailing = getPosition(from: newValue.end) {
                rightConstraint?.constant = trailing
                updateRightConstraint(with: .zero)
            }
            setNeedsLayout()
        }
    }
    
    public var progress: CMTime {
        get { positionBarTime ?? .zero }
        set { seek(to: newValue) }
    }
    
    private var positionBarTime: CMTime? {
        let barPosition = positionBar.frame.origin.x + assetPreview.contentOffset.x - handleWidth
        return getTime(from: barPosition)
    }

    private var minimumDistanceBetweenHandle: CGFloat {
        guard let asset = asset else { return 0 }
        return CGFloat(minDuration) * assetPreview.contentView.frame.width / CGFloat(asset.duration.seconds)
    }
}

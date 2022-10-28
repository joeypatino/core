//
//  VideoTrimmerThumb.swift
//  VideoTrimmer
//
//  Created by Andreas Verhoeven on 02/09/2020.
//  Copyright © 2020 Andreas Verhoeven. All rights reserved.
//

import UIKit

public final class VideoTrimmerThumb: UIView {
    public var borderColor: UIColor = UIColor.systemYellow {
        didSet { updateColor() }
    }
    public var thumbBackgroundColor: UIColor = UIColor.systemYellow {
        didSet { updateColor() }
    }
    public let leadingGrabber = UIControl()
    public let trailingGrabber = UIControl()
    
	private var isActive = false
    private let path = UIBezierPath(roundedRect: .init(origin: .zero, size: .init(width: 12, height: 48)), cornerRadius: 12)
    private lazy var leadingChevronImageView = UIImageView(image: CAShapeLayer(bezierPath: path, fillColor: UIColor(hex: "#7EDD9C")).image())
    private lazy var trailingChevronView = UIImageView(image: CAShapeLayer(bezierPath: path, fillColor: UIColor(hex: "#7EDD9C")).image())

    private let wrapperView = UIView()
    private let leadingView = UIView()
    private let trailingView = UIView()
    private let topView = UIView()
    private let bottomView = UIView()
    
    private let leftView = LeftRoundedView()
    private let rightView = RightRoundedView()
    
    public let handleWidth = CGFloat(14)
    public let handleInsetWidth = CGFloat(0)
    public let bordersWidth = CGFloat(4)

	// MARK: - Input
	@objc private func x(_ sender: Any) {

	}

	// MARK: - Private
	private func updateColor() {
		leadingView.backgroundColor = thumbBackgroundColor
		trailingView.backgroundColor = thumbBackgroundColor
        
		topView.backgroundColor = borderColor
		bottomView.backgroundColor = borderColor
        
        leftView.color = borderColor
        rightView.color = borderColor
	}

	private func setup() {

		leadingChevronImageView.contentMode = .scaleAspectFit
		trailingChevronView.contentMode = .scaleAspectFit

		leadingChevronImageView.tintColor = .white
		trailingChevronView.tintColor = .white

		leadingChevronImageView.tintAdjustmentMode = .normal
		trailingChevronView.tintAdjustmentMode = .normal

        leadingView.setLayerCornerRadius(4.0, maskCorners: .allCorners)
        trailingView.setLayerCornerRadius(4.0, maskCorners: .allCorners)

		leadingView.addSubview(leadingChevronImageView)
		trailingView.addSubview(trailingChevronView)

        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = .zero
        wrapperView.layer.shadowRadius = 2
        wrapperView.layer.shadowOpacity = 0.25
        
		wrapperView.addSubview(topView)
		wrapperView.addSubview(bottomView)

        wrapperView.addSubview(leftView)
        wrapperView.addSubview(rightView)
        wrapperView.addSubview(leadingView)
        wrapperView.addSubview(trailingView)
        
		addSubview(wrapperView)

		wrapperView.addSubview(leadingGrabber)
		wrapperView.addSubview(trailingGrabber)

		updateColor()
	}

	// MARK: - UIView

    public override func layoutSubviews() {
		super.layoutSubviews()

		var size = bounds.size
		wrapperView.frame = CGRect(origin: .zero, size: size)
        
        size = bounds.insetBy(dx: 0, dy: 25).size
        let offset = ((bounds.height - size.height) / 2)
        let leadingFrame = CGRect(x: 0, y: offset, width: handleWidth, height: size.height)
        let trailingFrame = CGRect(x: bounds.width - handleWidth, y: offset, width: handleWidth, height: size.height)
        
		topView.frame = CGRect(x: handleWidth,
                               y: 0,
                               width: bounds.width - handleWidth * 2,
                               height: bordersWidth)
		bottomView.frame = CGRect(x: handleWidth,
                                  y: bounds.height - bordersWidth,
                                  width: bounds.width - handleWidth * 2,
                                  height: bordersWidth)

        leftView.frame = CGRect(x: 5,// half left side width
                                y: 0,
                                width: leftView.intrinsicContentSize.width,
                                height: bounds.height)
        rightView.frame = CGRect(x: bounds.width - handleWidth,
                                 y: 0,
                                 width: rightView.intrinsicContentSize.width,
                                 height: bounds.height)

		let chevronHorizontalInset = CGFloat(5)
		let chevronVerticalInset = CGFloat(7)
		let chevronFrame = CGRect(x: chevronHorizontalInset,
                                  y: chevronVerticalInset,
                                  width: handleWidth - chevronHorizontalInset * 2,
                                  height: size.height - chevronVerticalInset * 2)

        leadingView.frame = leadingFrame
        trailingView.frame = trailingFrame

		leadingChevronImageView.frame = chevronFrame
		trailingChevronView.frame = chevronFrame

		leadingGrabber.frame = leadingFrame
		trailingGrabber.frame = trailingFrame
	}

	override init(frame: CGRect) {
		super.init(frame: frame)
		setup()
	}

	required init?(coder: NSCoder) {
		super.init(coder: coder)
		setup()
	}
}

private class LeftRoundedView: UIView {
    public var color: UIColor = .white
    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: 12, y: 2))
        rectanglePath.addLine(to: CGPoint(x: 8, y: 2))
        rectanglePath.addCurve(to: CGPoint(x: 4.68, y: 2.25), controlPoint1: CGPoint(x: 6.24, y: 2), controlPoint2: CGPoint(x: 5.47, y: 2))
        rectanglePath.addLine(to: CGPoint(x: 4.53, y: 2.28))
        rectanglePath.addCurve(to: CGPoint(x: 2.3, y: 4.4), controlPoint1: CGPoint(x: 3.49, y: 2.64), controlPoint2: CGPoint(x: 2.68, y: 3.42))
        rectanglePath.addCurve(to: CGPoint(x: 2, y: 7.81), controlPoint1: CGPoint(x: 2, y: 5.3), controlPoint2: CGPoint(x: 2, y: 6.14))
        rectanglePath.addLine(to: CGPoint(x: 2, y: 72.19))
        rectanglePath.addCurve(to: CGPoint(x: 2.26, y: 75.45), controlPoint1: CGPoint(x: 2, y: 73.86), controlPoint2: CGPoint(x: 2, y: 74.7))
        rectanglePath.addLine(to: CGPoint(x: 2.3, y: 75.6))
        rectanglePath.addCurve(to: CGPoint(x: 4.53, y: 77.72), controlPoint1: CGPoint(x: 2.68, y: 76.58), controlPoint2: CGPoint(x: 3.49, y: 77.36))
        rectanglePath.addCurve(to: CGPoint(x: 12, y: 78), controlPoint1: CGPoint(x: 5.47, y: 78), controlPoint2: CGPoint(x: 10.24, y: 78))
        UIColor.white.setStroke()
        rectanglePath.lineWidth = 4
        rectanglePath.lineCapStyle = .round
        rectanglePath.lineJoinStyle = .round
        rectanglePath.stroke()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 10, height: UIView.noIntrinsicMetric)
    }
}


private class RightRoundedView: UIView {
    public var color: UIColor = .white
    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func draw(_ rect: CGRect) {
        let rectanglePath = UIBezierPath()
        rectanglePath.move(to: CGPoint(x: -2, y: 2))
        rectanglePath.addLine(to: CGPoint(x: 2, y: 2))
        rectanglePath.addCurve(to: CGPoint(x: 5.32, y: 2.25), controlPoint1: CGPoint(x: 3.76, y: 2), controlPoint2: CGPoint(x: 4.53, y: 2))
        rectanglePath.addLine(to: CGPoint(x: 5.47, y: 2.28))
        rectanglePath.addCurve(to: CGPoint(x: 7.7, y: 4.4), controlPoint1: CGPoint(x: 6.51, y: 2.64), controlPoint2: CGPoint(x: 7.32, y: 3.42))
        rectanglePath.addCurve(to: CGPoint(x: 8, y: 7.81), controlPoint1: CGPoint(x: 8, y: 5.3), controlPoint2: CGPoint(x: 8, y: 6.14))
        rectanglePath.addLine(to: CGPoint(x: 8, y: 72.19))
        rectanglePath.addCurve(to: CGPoint(x: 7.74, y: 75.45), controlPoint1: CGPoint(x: 8, y: 73.86), controlPoint2: CGPoint(x: 8, y: 74.7))
        rectanglePath.addLine(to: CGPoint(x: 7.7, y: 75.6))
        rectanglePath.addCurve(to: CGPoint(x: 5.47, y: 77.72), controlPoint1: CGPoint(x: 7.32, y: 76.58), controlPoint2: CGPoint(x: 6.51, y: 77.36))
        rectanglePath.addCurve(to: CGPoint(x: -2, y: 78), controlPoint1: CGPoint(x: 4.53, y: 78), controlPoint2: CGPoint(x: -0.24, y: 78))
        UIColor.white.setStroke()
        rectanglePath.lineWidth = 4
        rectanglePath.lineCapStyle = .round
        rectanglePath.lineJoinStyle = .round
        rectanglePath.stroke()
    }
    
    override var intrinsicContentSize: CGSize {
        .init(width: 10, height: UIView.noIntrinsicMetric)
    }
}

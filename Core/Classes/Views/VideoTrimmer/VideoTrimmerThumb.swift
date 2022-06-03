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
    
    public let leadingGrabber = UIControl()
    public let trailingGrabber = UIControl()
    
	private var isActive = false
    private var leadingChevronImageView = UIImageView(image: UIImage(systemName: "chevron.compact.left"))
    private var trailingChevronView = UIImageView(image: UIImage(systemName: "chevron.compact.right"))

    private let wrapperView = UIView()
    private let leadingView = UIView()
    private let trailingView = UIView()
    private let topView = UIView()
    private let bottomView = UIView()

    public let chevronWidth = CGFloat(16)
    public let edgeHeight = CGFloat(4)

	// MARK: - Input
	@objc private func x(_ sender: Any) {

	}

	// MARK: - Private
	private func updateColor() {
		leadingView.backgroundColor = borderColor
		trailingView.backgroundColor = borderColor
		topView.backgroundColor = borderColor
		bottomView.backgroundColor = borderColor
	}

	private func setup() {

		leadingChevronImageView.contentMode = .scaleAspectFill
		trailingChevronView.contentMode = .scaleAspectFill

		leadingChevronImageView.tintColor = .white
		trailingChevronView.tintColor = .white

		leadingChevronImageView.tintAdjustmentMode = .normal
		trailingChevronView.tintAdjustmentMode = .normal

		leadingView.layer.cornerRadius = 0
		leadingView.layer.cornerCurve = .continuous
		leadingView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]

		trailingView.layer.cornerRadius = 6
		trailingView.layer.cornerCurve = .continuous
		trailingView.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMaxXMinYCorner]

		leadingView.addSubview(leadingChevronImageView)
		trailingView.addSubview(trailingChevronView)

        wrapperView.layer.shadowColor = UIColor.black.cgColor
        wrapperView.layer.shadowOffset = .zero
        wrapperView.layer.shadowRadius = 2
        wrapperView.layer.shadowOpacity = 0.25

		wrapperView.addSubview(leadingView)
		wrapperView.addSubview(trailingView)
		wrapperView.addSubview(topView)
		wrapperView.addSubview(bottomView)
		addSubview(wrapperView)

		wrapperView.addSubview(leadingGrabber)
		wrapperView.addSubview(trailingGrabber)

		updateColor()
	}

	// MARK: - UIView

    public override func layoutSubviews() {
		super.layoutSubviews()

		let size = bounds.size

		wrapperView.frame = CGRect(origin: .zero, size: size)

		leadingView.frame = CGRect(x: 0, y: 0, width: chevronWidth, height: bounds.height)
		trailingView.frame = CGRect(x: bounds.width - chevronWidth, y: 0, width: chevronWidth, height: bounds.height)
		topView.frame = CGRect(x: chevronWidth, y: 0, width: bounds.width - chevronWidth * 2, height: edgeHeight)
		bottomView.frame = CGRect(x: chevronWidth, y: bounds.height - edgeHeight, width: bounds.width - chevronWidth * 2, height: edgeHeight)

		let chevronHorizontalInset = CGFloat(6)
		let chevronVerticalInset = CGFloat(12)
		let chevronFrame = CGRect(x: chevronHorizontalInset, y: chevronVerticalInset, width: chevronWidth - chevronHorizontalInset * 2, height: size.height - chevronVerticalInset * 2)

		leadingChevronImageView.frame = chevronFrame
		trailingChevronView.frame = chevronFrame

		leadingGrabber.frame = leadingView.frame
		trailingGrabber.frame = trailingView.frame
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


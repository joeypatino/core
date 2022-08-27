//
//  HandlerView.swift
//  PryntTrimmerView
//
//  Created by HHK on 27/03/2017.
//  Copyright © 2017 Prynt. All rights reserved.
//

import Foundation
import UIKit

class PositionBar: UIView {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitFrame = bounds.insetBy(dx: -30, dy: 0)
        return hitFrame.contains(point) ? self : nil
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = bounds.insetBy(dx: -30, dy: 0)
        return hitFrame.contains(point)
    }
}

class LeftHandlerView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point) ? self : nil
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point)
    }
    
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


class RightHandlerView: UIView {

    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point) ? self : nil
    }
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        let hitFrame = bounds.insetBy(dx: -20, dy: -20)
        return hitFrame.contains(point)
    }
    
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

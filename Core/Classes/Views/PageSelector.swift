import UIKit

public protocol PageIndicatorViewDelegate: AnyObject {
    func indicatorView(_ view: PageIndicatorView, didSelectIndex idx: Int)
}

public final class PageIndicatorView: UIView {
    public weak var delegate: PageIndicatorViewDelegate?

    public var numberOfSteps: Int = 0 {
        didSet { update() }
    }
    public var indicatorSize: CGSize = CGSize(width: 14, height: 14) {
        didSet { update() }
    }
    public var spacing: CGFloat = 10 {
        didSet { update() }
    }
    public var selectionColor: UIColor = .black {
        didSet { update() }
    }
    public var unselectedColor: UIColor = .lightGray {
        didSet { update() }
    }
    public var selectedIdx: Int = 0 {
        didSet {
            delegate?.indicatorView(self, didSelectIndex: selectedIdx)
            update()
        }
    }

    public init() {
        super.init(frame: .zero)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        backgroundColor = .clear
    }
    
    public override var intrinsicContentSize: CGSize {
        let numOfSpaces = max(numberOfSteps - 1, 0)
        let indicatorsWidth = indicatorSize.width * CGFloat(numberOfSteps)
        let spacesWidth = (CGFloat(numOfSpaces) * spacing)
        return CGSize(width: indicatorsWidth + spacesWidth,
                      height: indicatorSize.height)
    }
    
    private func update() {
        invalidateIntrinsicContentSize()
        setNeedsDisplay()
    }
    
    public func reload() {
        update()
    }
    
    public override func draw(_ rect: CGRect) {
        guard let ctx = UIGraphicsGetCurrentContext() else { return }
        ctx.clear(rect)
        
        for (idx, rect) in indicatorsRects(bounds).enumerated() {
            let path = UIBezierPath(roundedRect: rect, cornerRadius: indicatorSize.width).cgPath
            ctx.addPath(path)
            let color = selectedIdx == idx ? selectionColor : unselectedColor
            ctx.setFillColor(color.cgColor)
            ctx.fillPath()
        }
    }
    
    private func indicatorsRects(_ rect: CGRect) -> [CGRect] {
        var origin = CGPoint.zero
        return (0 ..< numberOfSteps).map { idx in
            let rect = CGRect(origin: origin, size: indicatorSize)
            origin = CGPoint(x: origin.x + indicatorSize.width + spacing, y: origin.y)
            return rect
        }
    }
    
    public override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard
            let touchedPoint = touches.first?.location(in: self),
            let indicatorIdx = indicatorsRects(bounds).firstIndex(where: { $0.contains(touchedPoint) })
            else { return }
        selectedIdx = indicatorIdx
    }
}

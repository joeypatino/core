import UIKit

public class Spacer: UIView {
    public enum Orientation: Codable {
        case horizonal(width: CGFloat? = nil)
        case vertical(height: CGFloat? = nil)
    }
    
    private var layoutConstraints: [NSLayoutConstraint] = []
    
    public init(orientation: Orientation, huggingPriority: Float = 250) {
        super.init(frame: .zero)
        updateOrientation(orientation, huggingPriority: huggingPriority)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        backgroundColor = .clear
    }
    
    private func layout() {
    }
    
    public func updateOrientation(_ orientation: Orientation, huggingPriority: Float = 250) {
        horizontalHugging = 250
        verticalHugging = 250
        NSLayoutConstraint.deactivate(layoutConstraints)
        layoutConstraints.removeAll()
        switch orientation {
        case .horizonal(width: let width):
            width.map { layoutConstraints.append(widthAnchor.equalToConstant($0)) }
            horizontalHugging = huggingPriority
        case .vertical(height: let height):
            height.map { layoutConstraints.append(heightAnchor.equalToConstant($0)) }
            verticalHugging = huggingPriority
        }
    }
}

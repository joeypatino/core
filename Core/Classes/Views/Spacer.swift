import UIKit

public class Spacer: UIView {
    public enum Orientation: Codable {
        case horizonal(width: CGFloat? = nil)
        case vertical(height: CGFloat? = nil)
    }
    
    public init(orientation: Orientation, huggingPriority: Float = 250) {
        super.init(frame: .zero)
        switch orientation {
        case .horizonal(width: let width):
            width.map { _ = widthAnchor.equalToConstant($0) }
            horizontalHugging = huggingPriority
        case .vertical(height: let height):
            height.map { _ = heightAnchor.equalToConstant($0) }
            verticalHugging = huggingPriority
        }
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
}

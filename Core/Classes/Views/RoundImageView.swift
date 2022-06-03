import UIKit

public final class RoundImageView: RoundView {
    public var image: UIImage? {
        get { view.image }
        set { view.image = newValue }
    }
    private var insets: CGSize
    private let view: UIImageView
    public init(view: UIImageView, insets: CGSize = .init(width: 5, height: 5)) {
        self.view = view
        self.insets = insets
        super.init(frame: view.bounds)
        layout()
        configure()
    }
    
    convenience public init(image: UIImage?, insets: CGSize = .zero) {
        self.init(view: UIImageView(image: image), insets: insets)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func layout() {
        view.embed(in: self, inset: UIEdgeInsets(top: insets.height/2, left: insets.width/2, bottom: insets.height/2, right: insets.width/2))
    }
    
    private func configure() {
        backgroundColor = .white
    }
}

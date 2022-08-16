import UIKit
import AVFoundation

public final class VideoTimelineCell: UICollectionViewCell {
    private class SelectedVideoTimelineCell: UIView {
        init() {
            super.init(frame: .zero)
            setup()
            layout()
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        private func setup() {
            
        }
        
        private func layout() {
            
        }
    }
    
    public var onDelete:() -> Void = {}
    private let container = UIView()
    private let image = UIImageView(contentMode: .scaleAspectFill)
    private let duration = UILabel(font: .systemFont(ofSize: 12.0, weight: .medium), color: .white, alignment: .center)
    private let delete = SmallButton(insets: .init(width: 15, height: 15))

    public var isAnimating: Bool = false {
        didSet {
            delete.isVisible = isAnimating
            isAnimating ? wiggle() : stopWiggle()
        }
    }
    
    public var hasFocus: Bool = false {
        didSet { container.setBorder(.white, width: hasFocus ? 3.0 : 0) }
    }
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func prepareForReuse() {
        super.prepareForReuse()
        setImage(UIImage())
        hasFocus = false
        isAnimating = false
    }
    
    private func setup() {
        selectedBackgroundView = SelectedVideoTimelineCell()
        container.clipsToBounds = true
        container.setLayerCornerRadius(8, maskCorners: .allCorners)
        
        delete.clipsToBounds = true
        delete.setLayerCornerRadius(10, maskCorners: .allCorners)
        delete.setAttributedTitle(NSAttributedString(string: "-", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.white]), for: .normal)
        delete.addTarget(self, action: #selector(onDeleteAction(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        container.embed(in: contentView, inset: .init(top: 10, left: 0, bottom: 0, right: 10))
        image.embed(in: container)
        
        container.addAutoLayoutSubview(duration)
        duration.bottomAnchor.equalTo(container.bottomAnchor).constant(-4)
        duration.centerXAnchor.equalTo(container.centerXAnchor)
        
        contentView.addAutoLayoutSubview(delete)
        delete.centerYAnchor.equalTo(container.topAnchor)
        delete.centerXAnchor.equalTo(container.trailingAnchor)
        delete.widthAnchor.equalToConstant(20)
        delete.heightAnchor.equalToConstant(20)
    }
    
    public func setDuration(_ duration: CMTime) {
        self.duration.text = duration.humanReadable
    }
    
    public func setImage(_ image: UIImage) {
        self.image.image = image
    }

    public func getImage() -> UIImage? {
        self.image.image
    }
    
    @objc private func onDeleteAction(_ sender: UIButton) {
        onDelete()
    }
}

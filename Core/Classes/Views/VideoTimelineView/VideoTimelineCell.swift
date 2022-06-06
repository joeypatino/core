import UIKit

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
    
    private let image = UIImageView(contentMode: .scaleAspectFill)
    private let duration = UILabel(font: .systemFont(ofSize: 12.0, weight: .medium), color: .white, alignment: .center)
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
    }
    
    private func setup() {
        selectedBackgroundView = SelectedVideoTimelineCell()
        image.clipsToBounds = true
        setLayerCornerRadius(2, maskCorners: .allCorners)
    }
    
    private func layout() {
        image.embed(in: contentView)
        contentView.addAutoLayoutSubview(duration)
        duration.bottomAnchor.equalTo(contentView.bottomAnchor).constant(-4)
        duration.leadingAnchor.equalTo(contentView.leadingAnchor).constant(4)
    }
    
    public func setDuration(_ seconds: Float64) {
        duration.text = "\(seconds.truncate(to: 1))s"
    }
    
    public func setImage(_ image: UIImage) {
        self.image.image = image
    }

    public func getImage() -> UIImage? {
        self.image.image
    }
}

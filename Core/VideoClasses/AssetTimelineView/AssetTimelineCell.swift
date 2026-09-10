import UIKit
import AVFoundation
import Core

public typealias Trimmer = VideoTrimmer
//public typealias Trimmer = TrimmerView

public final class AssetTimelineCell: UICollectionViewCell {
    private class SelectedAssetTimelineCell: UIView {
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
    public var onCollapse:() -> Void = {}
    public var onTrimEvent: (Trimmer.Event, Trimmer) -> Void = { _, _ in }
    public var image: UIImage? { didSet { thumb.image = image } }
    public var imageGenerator: AVAssetImageGenerator? {
        didSet {
            trim.imageGenerator = imageGenerator
            imageGenerator == nil ? trim.fadeOut(duration: 0.1) : trim.fadeIn(duration: 0.1)
        }
    }
    public let trim = Trimmer()
    private let container = UIView()
    private let thumbstrip = UIImageView(contentMode: .scaleAspectFill)
    private let thumb = UIImageView(contentMode: .scaleAspectFill)
    private let duration = UILabel(font: .systemFont(ofSize: 12.0, weight: .medium), color: .white, alignment: .center)
    private let delete = SmallButton(insets: .init(width: 15, height: 15))
    private lazy var tapGesture = UITapGestureRecognizer(target: self, action: #selector(onCollapseAction(_:)))
    
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
        image = nil
        hasFocus = false
        isAnimating = false
    }
    
    private func setup() {
        selectedBackgroundView = SelectedAssetTimelineCell()
        container.clipsToBounds = true
        container.setLayerCornerRadius(8, maskCorners: .allCorners)
        trim.alpha = 0
        trim.horizontalInset = .zero
        trim.canZoomedIn = false
        trim.borderColor = .white
        trim.thumbBackgroundColor = .white
//        trim.handleColor = .white
//        trim.handleInsetColor = UIColor(red: 0.494, green: 0.867, blue: 0.612, alpha: 1)
//        trim.mainColor = .black
//        trim.borderColor = .white
//        trim.borderWidth = 4
        trim.addTarget(self, action: #selector(onCollapseAction(_:)), for: .touchUpInside)
        
        trim.addTarget(self, action: #selector(didBeginTrimming(_:)), for: Trimmer.didBeginTrimming)
        trim.addTarget(self, action: #selector(selectedRangeChanged(_:)), for: Trimmer.selectedRangeChanged)
        trim.addTarget(self, action: #selector(didEndTrimming(_:)), for: Trimmer.didEndTrimming)
        trim.addTarget(self, action: #selector(didBeginScrubbing(_:)), for: Trimmer.didBeginScrubbing)
        trim.addTarget(self, action: #selector(progressChanged(_:)), for: Trimmer.progressChanged)
        trim.addTarget(self, action: #selector(didEndScrubbing(_:)), for: Trimmer.didEndScrubbing)
        
        delete.clipsToBounds = true
        delete.setLayerCornerRadius(10, maskCorners: .allCorners)
        delete.setAttributedTitle(NSAttributedString(string: "-", attributes: [.font: UIFont.systemFont(ofSize: 18, weight: .bold), .foregroundColor: UIColor.white]), for: .normal)
        delete.addTarget(self, action: #selector(onDeleteAction(_:)), for: .touchUpInside)
    }
    
    private func layout() {
        container.embed(in: contentView, inset: .init(top: 10, left: 10, bottom: 0, right: 10))
        thumb.embed(in: container)
        trim.embed(in: contentView, inset: .init(top: 10, left: 0, bottom: 0, right: 0))
        
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
        
    @objc private func onDeleteAction(_ sender: UIButton) {
        onDelete()
    }
    
    @objc private func onCollapseAction(_ sender: UIControl) {
        onCollapse()
    }
    
    @objc private func didBeginTrimming(_ sender: UIControl) {
        onTrimEvent(.didBeginTrimming, trim)
    }
    
    @objc private func selectedRangeChanged(_ sender: UIControl) {
        onTrimEvent(.selectedRangeChanged, trim)
    }
    
    @objc private func didEndTrimming(_ sender: UIControl) {
        setDuration(trim.selectedRange.duration)
        onTrimEvent(.didEndTrimming, trim)
    }
    
    @objc private func didBeginScrubbing(_ sender: UIControl) {
        onTrimEvent(.didBeginScrubbing, trim)
    }
    
    @objc private func progressChanged(_ sender: UIControl) {
        onTrimEvent(.progressChanged, trim)
    }
    
    @objc private func didEndScrubbing(_ sender: UIControl) {
        onTrimEvent(.didEndScrubbing, trim)
    }
}

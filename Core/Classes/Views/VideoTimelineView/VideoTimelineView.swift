import UIKit
import AVKit

public protocol VideoTimelineViewDelegate: AnyObject {
    func view(_ videoTimeline: VideoTimelineView, didEditComposition composition: Composition)
    func view(_ videoTimeline: VideoTimelineView, didSelectAsset asset: Asset)
}

public final class VideoTimelineView: UIView {
    public weak var delegate: VideoTimelineViewDelegate?
    public var isEditing: Bool = false {
        didSet { collection.visibleCells.forEach { ($0 as? VideoTimelineCell)?.isAnimating = isEditing } }
    }
    
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderGesture(_:)))
    private let collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    private var avComposition: AVComposition {
        composition.imageGenerator.asset as! AVComposition
    }
    private var selectedIndexPath = IndexPath(row: 0, section: 0)
    private var follow: (IndexPath) -> Void = { _ in }
    public var composition: Composition {
        didSet { update() }
    }
    public init(composition: Composition) {
        self.composition = composition
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: 90 + insets.verticalLength)
    }
    
    private func setup() {
        setupCollectionView()
        setLayerCornerRadius(6.0, maskCorners: .allCorners)
        
        longPressGesture.delaysTouchesBegan = true
        longPressGesture.minimumPressDuration = 0.2
        collection.addGestureRecognizer(longPressGesture)
    }
    
    private func layout() {
        collection.embed(in: self)
    }
    
    private func update() {
        collection.reloadData()
    }
    
    public func jumpToStart() {
        DispatchQueue.main.asyncAfter(delay: 0.35) {
            self.selectedIndexPath = IndexPath(row: 0, section: 0)
            guard !self.composition.videoLayers.isEmpty else { return }
            self.collection.scrollToItem(at: self.selectedIndexPath, at: .left, animated: true)
        }
    }
    
    public func updateCurrentTime(_ time: CMTime) {
        var offset = CMTime.zero
        let sequenced = composition.videoLayers.map { layer -> CMTimeRange in
            let time = layer.timeRange
            let range = CMTimeRange(start: offset, duration: time.duration)
            offset = CMTimeAdd(offset, time.duration)
            return range
        }
        guard let idx = sequenced.firstIndex(where: { $0.containsTime(time) }) else { return }
        let newIndexPath = IndexPath(row: idx, section: 0)
        let previousIndexPath = selectedIndexPath
        selectedIndexPath = newIndexPath
        if newIndexPath != previousIndexPath { Vibration.light.vibrate() }
        collection.reloadItems(at: [previousIndexPath, newIndexPath].compactMap { $0 })
        let visibleIndexPaths = collection.indexPathsForVisibleItems.sorted()
        if !visibleIndexPaths.contains(selectedIndexPath), !visibleIndexPaths.isEmpty {
            follow(newIndexPath)
        }
    }
    
    @objc private func reorderGesture(_ gesture: UILongPressGestureRecognizer) {
        switch(gesture.state) {
        case .began:
            Vibration.heavy.vibrate()
            isEditing = true
        default:
            break
        }
    }
}

extension VideoTimelineView {
    private func setupCollectionView() {
        follow = DispatchQueue.main.debounce(delay: 0.1) { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            let visibleIndexPaths = self.collection.indexPathsForVisibleItems
            guard !visibleIndexPaths.isEmpty else { return }
            var scrollPosition = UICollectionView.ScrollPosition.centeredHorizontally
            if indexPath.row > visibleIndexPaths.last!.row { scrollPosition = .right }
            else if indexPath.row < visibleIndexPaths.first!.row { scrollPosition = .left }
            UIView.animate(withDuration: 0.3) {
                guard !self.composition.videoLayers.isEmpty else { return }
                self.collection.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
            }
        }
        
        (collection.collectionViewLayout as! UICollectionViewFlowLayout).scrollDirection = .horizontal
        collection.register(VideoTimelineCell.self, forCellWithReuseIdentifier: String(describing: VideoTimelineCell.self))
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.dropDelegate = self
        collection.dragInteractionEnabled = true
        collection.dragDelegate = self
        // hack!
        collection.gestureRecognizers?.forEach {
            ($0 as? UILongPressGestureRecognizer)?.minimumPressDuration = 0.1
            //($0 as? UILongPressGestureRecognizer)?.addTarget(self, action: #selector(reorderGesture(_:)))
        }
        collection.reloadData()
    }
}

extension VideoTimelineView: UICollectionViewDragDelegate {
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoTimelineCell else {
            return []
        }
        guard let image = cell.getImage()?.scale(factor: 1.2) else {
            return []
        }

        return [UIDragItem(itemProvider: NSItemProvider(object: image))]
    }
    
    public func collectionView(_ collectionView: UICollectionView, dragPreviewParametersForItemAt indexPath: IndexPath) -> UIDragPreviewParameters? {
        let params = UIDragPreviewParameters()
        params.backgroundColor = .clear
        return params
    }
}

extension VideoTimelineView: UICollectionViewDropDelegate {
    public func collectionView(_ collectionView: UICollectionView, canHandle session: UIDropSession) -> Bool {
        true
    }

    public func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        guard let destinationIndexPath = coordinator.destinationIndexPath else {
            return
        }

        coordinator.items.forEach { dropItem in
            guard let sourceIndexPath = dropItem.sourceIndexPath else {
                return
            }

            collectionView.performBatchUpdates({
                if composition.exchange(layerAt: sourceIndexPath.row, with: destinationIndexPath.row) {
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
            }, completion: { _ in
                if self.selectedIndexPath == sourceIndexPath { self.selectedIndexPath = destinationIndexPath }
                collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
                self.delegate?.view(self, didEditComposition: self.composition)
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
            })
        }
    }

    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath? ) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

extension VideoTimelineView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let layers = composition.videoLayers
        let layer = layers[indexPath.row]
        let asset = layer.asset
        delegate?.view(self, didSelectAsset: asset)
    }
}

extension VideoTimelineView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        composition.videoLayers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoTimelineCell.self), for: indexPath) as? VideoTimelineCell else { preconditionFailure() }
        let layers = composition.videoLayers
        let layer = layers[indexPath.row]
        let asset = layer.asset
        cell.isAnimating = isEditing
        cell.hasFocus = indexPath == selectedIndexPath
        cell.setDuration(asset.duration)
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.deleteItem(atIndexPath: indexPath)
        }
        Task { cell.setImage((try? await asset.thumbnail(size: .init(width: 46, height: 74))) ?? UIImage()) }
        return cell
    }
    
    private func deleteItem(atIndexPath indexPath: IndexPath) {
        collection.performBatchUpdates({
            if composition.remove(layerAt: indexPath.row) != nil {
                collection.deleteItems(at: [indexPath])
            }
        }, completion: { _ in
            self.delegate?.view(self, didEditComposition: self.composition)
        })
    }
}

extension VideoTimelineView: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { .init(top: 12, left: 0, bottom: 12, right: 0) }
    private var interitemSpacing: CGFloat { 18.0 }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 62, height: 90)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { insets }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { insets.top }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { interitemSpacing }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { .zero }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { .zero }
}

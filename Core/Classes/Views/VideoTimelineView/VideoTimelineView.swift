import UIKit
import AVKit

public protocol VideoTimelineViewDelegate: AnyObject {
    func view(_ videoTimeline: VideoTimelineView, didEditComposition composition: Composition)
    func view(_ videoTimeline: VideoTimelineView, didSelectAsset asset: Asset)
}

public final class VideoTimelineView: UIView {
    public weak var delegate: VideoTimelineViewDelegate?
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
        return CGSize(width: UIView.noIntrinsicMetric, height: 80)
    }
    
    private func setup() {
        setupCollectionView()
        setLayerCornerRadius(6.0, maskCorners: .allCorners)
    }
    
    private func layout() {
        collection.embed(in: self)
    }
    
    private func update() {
        collection.reloadData()
    }
    
    private func showTracks(_ composition: AVComposition) {
        let tracks:[AVCompositionTrack] = composition.tracks
        print(tracks.map { track -> [String: Any] in
            if !track.isEnabled { return [:] }
            let segments: [AVCompositionTrackSegment] = track.segments
            return ["track.trackID": track.trackID,
                    "track.mediaType": track.mediaType,
                    "track.start": track.timeRange.start.value,
                    "track.duration": track.timeRange.duration.value,
                    "segments": segments.map { segment in
                ["segment.sourceTrackID": segment.sourceTrackID,
                 "segment.sourceURL": segment.sourceURL?.lastPathComponent ?? "--",
                 "segment.source.start": segment.timeMapping.source.start.value,
                 "segment.source.duration": segment.timeMapping.source.duration.value]
            }]
        }.jsonString(prettify: true) ?? "[]")
    }
    
    public func jumpToStart() {
        DispatchQueue.main.asyncAfter(delay: 0.35) {
            self.selectedIndexPath = IndexPath(row: 0, section: 0)
            guard !self.composition.layers.isEmpty else { return }
            self.collection.scrollToItem(at: self.selectedIndexPath, at: .left, animated: true)
        }
    }
    
    public func updateCurrentTime(_ time: CMTime) {
        var offset = CMTime.zero
        let sequenced = composition.layers.map { layer -> CMTimeRange in
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
                guard !self.composition.layers.isEmpty else { return }
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
        collection.reloadData()
    }
}

extension VideoTimelineView: UICollectionViewDragDelegate {
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoTimelineCell else { return [] }
        guard let image = cell.getImage() else {
            return []
        }
        
        let item = NSItemProvider(object: image)
        let dragItem = UIDragItem(itemProvider: item)
        return [dragItem]
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
        let layers = composition.layers
        let layer = layers[indexPath.row]
        let asset = layer.asset
        delegate?.view(self, didSelectAsset: asset)
    }
}

extension VideoTimelineView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        composition.layers.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: VideoTimelineCell.self), for: indexPath) as? VideoTimelineCell else { preconditionFailure() }
        let layers = self.composition.layers
        let layer = layers[indexPath.row]
        let asset = layer.asset
        if indexPath == selectedIndexPath {
            cell.setBorder(.white, width: 1.0)
        } else {
            cell.setBorder(.white, width: 0.0)
        }
        cell.setDuration(CMTimeGetSeconds(asset.duration))
        Task { cell.setImage((try? await asset.thumbnail(size: .init(width: 150, height: 150))) ?? UIImage()) }
        return cell
    }
}

extension VideoTimelineView: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { .init(top: 12, left: 0, bottom: 12, right: 0) }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let height = collectionView.bounds.height - insets.verticalLength
        return .init(width: height, height: height)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { insets }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { insets.top }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat { insets.right }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { .zero }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { .zero }
}

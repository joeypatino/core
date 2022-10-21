import UIKit
import AVKit

public protocol AssetViewModel: AnyObject {
    /// the asset we are managing
    var asset: Asset { get }
    
    /// the edited asset we are managing
    var editedAsset: Asset { get }

    /// an image generator that wil return thumbnail images for this asset. It must be prepared to
    /// return images based on the `timeRange` (.zero based startTime!)
    var imageGenerator: AVAssetImageGenerator { get }
    
    /// the time range of the asset, always using a base start offset of .zero, regardless of the assets actual
    /// startTime in its timeline or it's `editedTimeRange`
    var timeRange: CMTimeRange { get }
    
    /// the time range of the asset, within the main timeline
    var timeRangeInTimeline: CMTimeRange { get }
    
    // the selected time range of the asset, in relative time range scale (i.e. based on .zero start time)
    var selectedTimeRange: CMTimeRange { get set }
    
    /// the real duration of the asset
    var duration: CMTime { get }
    
    // an av player item representing the edited asset
    func playerItem(size: CGSize) -> AVPlayerItem?
    
    func thumbnail(size: CGSize) async throws -> UIImage
}

extension AssetViewModel {
    /// the real start time of the asset, in relation its position in the timeline
    var startTime: CMTime { timeRangeInTimeline.start }
}

public protocol AssetTimelineViewDataSource: AnyObject {
    func viewAssetsInTimeline(_ assetTimeline: AssetTimelineView) -> [AssetViewModel]
}

public protocol AssetTimelineViewDelegate: AnyObject {
    func viewDidEditAssets(_ assetTimeline: AssetTimelineView)
    func view(_ assetTimeline: AssetTimelineView, didChangeDisplayMode mode: AssetTimelineView.DisplayMode)
    func view(_ assetTimeline: AssetTimelineView, didSelectAsset asset: Asset)
    func view(_ assetTimeline: AssetTimelineView, deleteAssetAtIndex index: Int) -> Bool
    func view(_ assetTimeline: AssetTimelineView, exchangeAssetAtIndex sourceIndex: Int, withAssetAtIndex destinationIndex: Int) -> Bool
    
    func view(_ assetTimeline: AssetTimelineView, didStartTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ assetTimeline: AssetTimelineView, didContinueTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ assetTimeline: AssetTimelineView, didEndTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    
    func view(_ assetTimeline: AssetTimelineView, didStartScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ assetTimeline: AssetTimelineView, didContinueScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ assetTimeline: AssetTimelineView, didEndScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
}

extension AssetTimelineViewDelegate {
    public func view(_ assetTimeline: AssetTimelineView, didChangeDisplayMode mode: AssetTimelineView.DisplayMode) {}
    public func view(_ assetTimeline: AssetTimelineView, didSelectAsset asset: Asset) { }
    public func view(_ assetTimeline: AssetTimelineView, deleteAssetAtIndex index: Int) -> Bool { false }
    public func view(_ assetTimeline: AssetTimelineView, exchangeAssetAtIndex sourceIndex: Int, withAssetAtIndex destinationIndex: Int) -> Bool { false }
    
    public func view(_ assetTimeline: AssetTimelineView, didStartTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ assetTimeline: AssetTimelineView, didContinueTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ assetTimeline: AssetTimelineView, didEndTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    
    public func view(_ assetTimeline: AssetTimelineView, didStartScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ assetTimeline: AssetTimelineView, didContinueScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ assetTimeline: AssetTimelineView, didEndScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
}

public final class AssetTimelineView: UIView {
    static let UnExpandedCellIndexPath = IndexPath(row: -1, section: 0)
    static let DefaultSelectedCellIndexPath = IndexPath(row: 0, section: 0)
    
    public enum DisplayMode {
        case trim(IndexPath)
        case thumbs
    }
    public weak var datasource: AssetTimelineViewDataSource?
    public weak var delegate: AssetTimelineViewDelegate?
    public var isEditing: Bool = false {
        didSet {
            collection.visibleCells.forEach { ($0 as? AssetTimelineCell)?.isAnimating = isEditing }
            if !isEditing { mode = .thumbs }
        }
    }
    public var mode: AssetTimelineView.DisplayMode = .thumbs {
        didSet {
            if case .thumbs = oldValue, case .thumbs = mode { return }
            switch oldValue {
            case .trim(let trimmingIndexPath):
                updateMode(previousTrimmingIndexPath: trimmingIndexPath)
            case .thumbs:
                updateMode(previousTrimmingIndexPath: AssetTimelineView.UnExpandedCellIndexPath)
            }
        }
    }
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderGesture(_:)))
    private lazy var flowLayout: UICollectionViewFlowLayout = {
        let flowLayout = UICollectionViewFlowLayout()
        flowLayout.scrollDirection = .horizontal
        return flowLayout
    }()
    private lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    private var selectedIndexPath = AssetTimelineView.DefaultSelectedCellIndexPath
    private var isExpanded: Bool {
        if case .trim = mode { return true }
        return false
    }
    private var follow: (IndexPath) -> Void = { _ in }
    private var assetViewModels: [AssetViewModel] = []
    private var assets: [Asset] { assetViewModels.map { $0.asset } }
    private var afterCollapse: () -> Void = {}
    public init() {
        super.init(frame: .zero)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override var intrinsicContentSize: CGSize {
        CGSize(width: UIView.noIntrinsicMetric, height: collapsedCellSize.height + insets.verticalLength)
    }
    
    private func setup() {
        setLayerCornerRadius(6.0, maskCorners: .allCorners)
        
        follow = DispatchQueue.main.debounce(delay: 0.1) { [weak self] (indexPath: IndexPath) in
            guard let self = self else { return }
            let visibleIndexPaths = self.collection.indexPathsForVisibleItems
            guard !visibleIndexPaths.isEmpty else { return }
            var scrollPosition = UICollectionView.ScrollPosition.centeredHorizontally
            if indexPath.row > visibleIndexPaths.last!.row { scrollPosition = .right }
            else if indexPath.row < visibleIndexPaths.first!.row { scrollPosition = .left }
            UIView.animate(withDuration: 0.3) {
                guard !self.assets.isEmpty else { return }
                self.collection.scrollToItem(at: indexPath, at: scrollPosition, animated: false)
            }
        }
        
        longPressGesture.minimumPressDuration = 0.2
        collection.addGestureRecognizer(longPressGesture)
        collection.register(AssetTimelineCell.self, forCellWithReuseIdentifier: String(describing: AssetTimelineCell.self))
        collection.contentInset.left = 32
        collection.contentInset.right = 32
        collection.backgroundColor = .clear
        collection.delegate = self
        collection.dataSource = self
        collection.dropDelegate = self
        collection.dragInteractionEnabled = true
        collection.dragDelegate = self
        collection.reloadData()
    }
    
    private func layout() {
        collection.embed(in: self)
    }
    
    private func update() {
        collection.reloadData()
    }
    
    public func reload() {
        assetViewModels = datasource?.viewAssetsInTimeline(self) ?? []
        collection.reloadData()
    }
    
    // MARK: Timeline Adjustment
    
    public func jumpToStart() {
        DispatchQueue.main.asyncAfter(delay: 0.35) {
            self.selectedIndexPath = IndexPath(row: 0, section: 0)
            guard !self.assets.isEmpty else { return }
            self.collection.scrollToItem(at: self.selectedIndexPath, at: .left, animated: true)
        }
    }
    
    public func updateCurrentTime(_ time: CMTime) {
        switch mode {
        case .thumbs:
            var offset = CMTime.zero
            let sequenced = assetViewModels.map { viewModels -> CMTimeRange in
                let time = viewModels.editedAsset.timeRange
                let range = CMTimeRange(start: offset, duration: time.duration)
                offset = CMTimeAdd(offset, time.duration)
                return range
            }
            guard let idx = sequenced.firstIndex(where: { $0.containsTime(time) }) else { return }
            let newIndexPath = IndexPath(row: idx, section: 0)
            let previousIndexPath = selectedIndexPath
            selectedIndexPath = newIndexPath
            guard !isExpanded else { return }
            if newIndexPath != previousIndexPath { Vibration.light.vibrate() }
            
            if let cell = collection.cellForItem(at: previousIndexPath) as? AssetTimelineCell {
                cell.hasFocus = false
            }
            if let cell = collection.cellForItem(at: newIndexPath) as? AssetTimelineCell {
                cell.hasFocus = true
            }
            
            let visibleIndexPaths = collection.indexPathsForVisibleItems.sorted()
            if !visibleIndexPaths.contains(selectedIndexPath), !visibleIndexPaths.isEmpty {
                follow(newIndexPath)
            }
        case .trim(let indexPath):
            guard let cell = expandedCell() else { return }
            let viewModel = assetViewModels[indexPath.row]
            let start = viewModel.selectedTimeRange.start
            cell.trim.progress = CMTimeAdd(time, start)
        }
    }

    public func delete(atIndex index: Int) {
        self.afterCollapse = {
            self.isEditing = false
            self.reload()
        }
        mode = .thumbs
    }
    
    public func remove(atIndex index: Int) {
        collection.performBatchUpdates({
            if remove(assetAt: index) {
                collection.deleteItems(at: [IndexPath(row: index, section: 0)])
            }
        }, completion: { _ in
            self.delegate?.viewDidEditAssets(self)
        })
    }
    
    // MARK: Expansion
    
    private func updateMode(previousTrimmingIndexPath: IndexPath) {
        delegate?.view(self, didChangeDisplayMode: mode)
        switch mode {
        case .thumbs:
            longPressGesture.isEnabled = true
            collection.dragInteractionEnabled = true
            collection.isScrollEnabled = true
            collapseItems(previousTrimmingIndexPath)
        case .trim(let indexPath):
            longPressGesture.isEnabled = false
            collection.dragInteractionEnabled = false
            collection.isScrollEnabled = false
            // first collapse the previously open cell
            collapseItems(previousTrimmingIndexPath)
            // now expand the newly selected cell
            expandItem(withViewModel: assetViewModels[indexPath.row])
        }
    }
    
    private func expandItem(withViewModel viewModel: AssetViewModel) {
        // remove the old image generator from any currently expanded cell
        if let cell = expandedCell() { cell.imageGenerator = nil }
        
        // get the index for the selected model
        guard let idx = assetViewModels.firstIndex(where: { $0.asset == viewModel.asset }) else {
            return
        }
        
        // then update the layout
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.flowLayout.invalidateLayout()
            self.collection.layoutIfNeeded()
            self.collection.scrollToItem(at: IndexPath(row: idx, section: 0), at: .centeredHorizontally, animated: true)
        },
                       completion: { _ in
            // after the layout is updated, show the trimmer control
            self.showTrimmer(withViewModel: viewModel)
        })
    }
    
    private func collapseItems(_ previousTrimmingIndexPath: IndexPath) {
        if let cell = collection.cellForItem(at: previousTrimmingIndexPath) as? AssetTimelineCell {
            // clear the image generator for the current cell
            cell.imageGenerator = nil
            // remove the observers for this cells trim control
            stopTrimControlObservers(forCell: cell)
        }
        // update the collection layout
        collection.performBatchUpdates({}) { _ in
            self.afterCollapse()
            self.afterCollapse = {}
        }
    }
    
    private func expandedCell() -> AssetTimelineCell? {
        guard isExpanded else { return nil }
        switch mode {
        case .trim(let indexPath):
            guard let cell = collection.cellForItem(at: indexPath) as? AssetTimelineCell else { return nil }
            return cell
        default:
            return nil
        }
    }
        
    // MARK: Trimmer Control
    
    private func showTrimmer(withViewModel viewModel: AssetViewModel) {
        guard let cell = expandedCell() else { return }
        
        // setup the observers for this cells trim control
        startTrimControlObservers(forCell: cell, withViewModel: viewModel)
        // set the image generator to supply some pretty thumbnails
        cell.imageGenerator = viewModel.imageGenerator

        DispatchQueue.main.async {
            UIView.performWithoutAnimation {
                let start = viewModel.editedAsset.timeRange.start.seconds
                let end = viewModel.editedAsset.timeRange.end.seconds
                cell.trim.selectedRange = CMTimeRange(start: CMTime(seconds: start, preferredTimescale: 600),
                                                      end: CMTime(seconds: end, preferredTimescale: 600))
                cell.trim.range = CMTimeRange(start: .zero, duration: viewModel.duration)
            }
        }
    }
    
    private func startTrimControlObservers(forCell cell: AssetTimelineCell, withViewModel viewModel: AssetViewModel) {
        cell.onTrimEvent = { [weak self] event, trim in
            guard let self = self else { return }
            switch event {
            case .didBeginTrimming:
                self.delegate?.view(self, didStartTrimming: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.selectedTime)
            case .selectedRangeChanged:
                self.delegate?.view(self, didContinueTrimming: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.selectedTime)
            case .didEndTrimming:
                self.delegate?.view(self, didEndTrimming: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.selectedTime)
            case .didBeginScrubbing:
                self.delegate?.view(self, didStartScrubbing: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.progress)
            case .progressChanged:
                self.delegate?.view(self, didContinueScrubbing: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.progress)
            case .didEndScrubbing:
                self.delegate?.view(self, didEndScrubbing: viewModel.asset, selectedTimeRange: trim.selectedRange, selectedTime: trim.progress)
            }
        }
    }
    
    private func stopTrimControlObservers(forCell cell: AssetTimelineCell) {
        cell.onTrimEvent = { _, _ in }
    }
    
    // MARK: Private
    
    private func exchange(assetAt sourceIndex: Int, with destinationIndex: Int) -> Bool {
        delegate?.view(self, exchangeAssetAtIndex: sourceIndex, withAssetAtIndex: destinationIndex) ?? false
    }
    
    private func remove(assetAt index: Int) -> Bool {
        delegate?.view(self, deleteAssetAtIndex: index) ?? false
    }
    
    // MARK: Actions
    
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

extension AssetTimelineView: UICollectionViewDragDelegate {
    public func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        guard let cell = collectionView.cellForItem(at: indexPath) as? AssetTimelineCell else {
            return []
        }
        guard let image = cell.image?.scale(factor: 1.2) else {
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

extension AssetTimelineView: UICollectionViewDropDelegate {
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
                if exchange(assetAt: sourceIndexPath.row, with: destinationIndexPath.row) {
                    collectionView.deleteItems(at: [sourceIndexPath])
                    collectionView.insertItems(at: [destinationIndexPath])
                }
            }, completion: { _ in
                if self.selectedIndexPath == sourceIndexPath { self.selectedIndexPath = destinationIndexPath }
                collectionView.reloadItems(at: [sourceIndexPath, destinationIndexPath])
                self.delegate?.viewDidEditAssets(self)
                coordinator.drop(dropItem.dragItem, toItemAt: destinationIndexPath)
            })
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath? ) -> UICollectionViewDropProposal {
        return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
    }
}

extension AssetTimelineView: UICollectionViewDelegate {
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        switch mode {
        case .thumbs:
            mode = .trim(indexPath)
        case .trim(let trimmingIndexPath):
            if indexPath == trimmingIndexPath {
                mode = .thumbs
            } else {
                mode = .trim(indexPath)
            }
        }
        let viewModel = assetViewModels[indexPath.row]
        delegate?.view(self, didSelectAsset: viewModel.asset)
    }
}

extension AssetTimelineView: UICollectionViewDataSource {
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        assets.count
    }
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        guard let cell = cell as? AssetTimelineCell else { return }
        let viewModel = assetViewModels[indexPath.row]
        Task {
            let image = try await viewModel.thumbnail(size: collapsedCellSize)
            DispatchQueue.main.async {
                cell.image = image
            }
        }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: String(describing: AssetTimelineCell.self), for: indexPath) as? AssetTimelineCell else { preconditionFailure() }
        let viewModel = assetViewModels[indexPath.row]
        cell.isAnimating = isEditing
        cell.hasFocus = indexPath == selectedIndexPath
        cell.setDuration(viewModel.selectedTimeRange.duration)
        cell.onDelete = { [weak self] in
            guard let self = self else { return }
            self.deleteItem(atIndexPath: indexPath)
        }
        cell.onCollapse = { [weak self] in
            guard let self = self else { return }
            self.mode = .thumbs
        }

        return cell
    }
    
    private func deleteItem(atIndexPath indexPath: IndexPath) {
        collection.performBatchUpdates({
            if remove(assetAt: indexPath.row) {
                collection.deleteItems(at: [indexPath])
            }
        }, completion: { _ in
            self.delegate?.viewDidEditAssets(self)
        })
    }
}

extension AssetTimelineView: UICollectionViewDelegateFlowLayout {
    private var insets: UIEdgeInsets { .init(top: 12, left: 0, bottom: 12, right: 0) }
    private var expandedCellSize: CGSize { .init(width: collection.bounds.inset(by: .init(top: 0, left: 32, bottom: 0, right: 32)).width, height: collapsedCellSize.height) }
    private var collapsedCellSize: CGSize { .init(width: 72, height: 90) }
    private var interItemSpacing: CGFloat {
        switch mode {
        case .thumbs: return 0.0
        case .trim: return 8.0
        }
    }

    private func cellSize(forIndexPath indexPath: IndexPath) -> CGSize {
        switch mode {
        case .trim(let trimIndexPath):
            return trimIndexPath == indexPath ? expandedCellSize : collapsedCellSize
        case .thumbs:
            return collapsedCellSize
        }
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        cellSize(forIndexPath: indexPath)
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        insets
//        let totalCellWidth = collapsedCellSize.width * CGFloat(assetViewModels.count)
//        let totalSpacingWidth = interItemSpacing * CGFloat(assetViewModels.count - 1)
//
//        var leftInset = (collectionView.bounds.width - CGFloat(totalCellWidth + totalSpacingWidth)) / 2
//        let rightInset = leftInset
//        if assetViewModels.count == 1 {
//            leftInset -= collapsedCellSize.width/2
//        }
//        return UIEdgeInsets(top: 0 - insets.top, left: leftInset - insets.left, bottom: 0 - insets.bottom, right: rightInset - insets.right)
    }
    
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { insets.top }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        interItemSpacing
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { .zero }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { .zero }
}

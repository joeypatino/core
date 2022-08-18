import UIKit
import AVKit

public protocol VideoTimelineViewDelegate: AnyObject {
    func view(_ videoTimeline: VideoTimelineView, didEditComposition composition: Composition)
    func view(_ videoTimeline: VideoTimelineView, didSelectAsset asset: Asset)
    
    func view(_ videoTimeline: VideoTimelineView, didStartTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ videoTimeline: VideoTimelineView, didContinueTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ videoTimeline: VideoTimelineView, didEndTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    
    func view(_ videoTimeline: VideoTimelineView, didStartScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ videoTimeline: VideoTimelineView, didContinueScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
    func view(_ videoTimeline: VideoTimelineView, didEndScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime)
}

extension VideoTimelineViewDelegate {
    public func view(_ videoTimeline: VideoTimelineView, didStartTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ videoTimeline: VideoTimelineView, didContinueTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ videoTimeline: VideoTimelineView, didEndTrimming asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    
    public func view(_ videoTimeline: VideoTimelineView, didStartScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ videoTimeline: VideoTimelineView, didContinueScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
    public func view(_ videoTimeline: VideoTimelineView, didEndScrubbing asset: Asset, selectedTimeRange timeRange: CMTimeRange, selectedTime: CMTime) {}
}

public final class VideoTimelineView: UIView {
    static let UnExpandedCellIndexPath = IndexPath(row: -1, section: 0)
    static let DefaultSelectedCellIndexPath = IndexPath(row: 0, section: 0)
    
    public weak var delegate: VideoTimelineViewDelegate?
    public var isEditing: Bool = false {
        didSet {
            collection.visibleCells.forEach { ($0 as? VideoTimelineCell)?.isAnimating = isEditing }
            if !isEditing { collapseItems() }
        }
    }
    
    private lazy var longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(reorderGesture(_:)))
    private lazy var flowLayout = FlowLayout(scrollDirection: .horizontal)
    private lazy var collection = UICollectionView(frame: .zero, collectionViewLayout: flowLayout)
    private var avComposition: AVComposition {
        composition.imageGenerator.asset as! AVComposition
    }
    private var selectedIndexPath = VideoTimelineView.DefaultSelectedCellIndexPath
    private var expandedIndexPath = VideoTimelineView.UnExpandedCellIndexPath {
        didSet {
            flowLayout.expandedIndexPath = expandedIndexPath
            longPressGesture.isEnabled = !isExpanded
            collection.dragInteractionEnabled = !isExpanded
            collection.isScrollEnabled = !isExpanded
        }
    }
    private var isExpanded: Bool { expandedIndexPath.row >= 0 }
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
        CGSize(width: UIView.noIntrinsicMetric, height: collapsedCellSize.height + insets.verticalLength)
    }
    
    private func setup() {
        setupCollectionView()
        setLayerCornerRadius(6.0, maskCorners: .allCorners)
        collection.contentInset.left = 32
        collection.contentInset.right = 32
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
        guard !isExpanded else { return }
        if newIndexPath != previousIndexPath { Vibration.light.vibrate() }
        collection.reloadItems(at: [previousIndexPath, newIndexPath].compactMap { $0 })
        let visibleIndexPaths = collection.indexPathsForVisibleItems.sorted()
        if !visibleIndexPaths.contains(selectedIndexPath), !visibleIndexPaths.isEmpty {
            follow(newIndexPath)
        }
    }

    public func expandItem(forAsset asset: Asset) {
        // first...
        // remove the old image generator from any currently expanded cell
        if let cell = expandedCell() { cell.imageGenerator = nil }
        
        // then get the index for the selected asset
        guard let idx = composition.videoLayers.firstIndex(where: { $0.asset == asset }) else {
            return
        }
        
        // if this asset is currently being trimmed, then collapse it and bail
        guard expandedIndexPath.row != idx else {
            collapseItems()
            return
        }
        
        // we have a new expanded cell. store it and update the collection layout
        expandedIndexPath = IndexPath(row: idx, section: 0)
        UIView.animate(withDuration: 0.4,
                       delay: 0,
                       usingSpringWithDamping: 1.0,
                       initialSpringVelocity: 0,
                       options: .curveEaseInOut,
                       animations: {
            self.flowLayout.invalidateLayout()
            self.collection.layoutIfNeeded()
            self.collection.scrollToItem(at: self.expandedIndexPath, at: .centeredHorizontally, animated: true)
        },
                       completion: { _ in
            // after the layout is updated, show the trimmer control
            self.showTrimmer(forAsset: asset)
        })
    }
    
    public func collapseItems() {
        // if we're not expanded then bail
        guard isExpanded else { return }
        
        if let cell = expandedCell() {
            // clear the image generator for the current cell
            cell.imageGenerator = nil
            // remove the observers for this cells trim control
            stopTrimControlObservers(forCell: cell)
        }
                
        // reset the expanded cell indexpath
        expandedIndexPath = VideoTimelineView.UnExpandedCellIndexPath
        
        // update the collection layout
        collection.performBatchUpdates({}) { _ in }
    }
    
    private func showTrimmer(forAsset asset: Asset) {
        // if we're not expanded then bail
        guard isExpanded else { return }
        guard let cell = expandedCell() else { return }
        
        // setup the observers for this cells trim control
        startTrimControlObservers(forCell: cell, withAsset: asset)
        
        // create and store the image thumbnail image generator for the timeline track
        let size = CGSize(width: collapsedCellSize.width * UIScreen.main.scale, height: collapsedCellSize.height * UIScreen.main.scale)
        cell.imageGenerator = AVAssetImageGenerator.create(from: [asset.source.trackItem], renderSize: size)

        print("[TimeRange] \(asset.timeRange.debugDescription)")
        print("[TimeRangeInTimeline] \(asset.timeRangeInTimeline.debugDescription)")

        DispatchQueue.main.async {
            cell.trim.range = asset.timeRange
            // this changes after we edit, which messes things up in the trimmer.. how make this work?
            //
            // maybe the better way is to just copy the asset and create a new editor when the user enter this "trimming" mode.
            // at this point we'd need to create (or update) the video player
            // create  a new composition / timeline, with only the single Asset (copy)
            // we could then disable the transitions on that Asset copy to make editing easier..
            // use that Asset to generate the imageGenerator
            // and then go from there..
            
            /// ** Steps **
            /// create a datasource for this control.. its becoming too complicated
            /// datasource can ask for "view mode" or "data provider" or whatever
            /// this ViewModel will hold the MutableAsset, Composition & ImageGenerator
            /// ** retain these ViewModels somewhere else. This lets us keep editing state
            /// but also revert if needed.
            ///
            /// also create a Mode enum for this class
            /// case trimming, case previewing
            /// on Mode enum associated value will be the IndexPath of the expanded cell
            /// ** (Remove the Custom CollectionViewLayout)
            ///
            /// Additional changes..
            /// Progress and SelectionRange times will now all be based to a .zero start time
            /// All of these calculation will be done inside the ViewModel (Protocol based!).
            /// so that this class should not be responsible for any CMTime calculations
            ///
            /// At the conclusion, this class will be resposible for manaaging the presentiion of
            /// Assets in a CollectionView & responding to touches in order to expand / collapse the UI.
            /// That's it!
            ///
            print("[Range] \(cell.trim.range.debugDescription)")
            DispatchQueue.main.async {
                //cell.trim.selectedRange = asset.source.resource.selectedTimeRange
                print("[SelectedRange] \(cell.trim.selectedRange.debugDescription)")
            }
        }
    }
    
    private func expandedCell() -> VideoTimelineCell? {
        guard isExpanded else { return nil }
        guard let cell = collection.cellForItem(at: expandedIndexPath) as? VideoTimelineCell else { return nil }
        return cell
    }
    
    private func startTrimControlObservers(forCell cell: VideoTimelineCell, withAsset asset: Asset) {
        cell.onTrimEvent = { [weak self] event, trim in
            func insetTimeRange(_ timeRange: CMTimeRange) -> CMTimeRange {
                CMTimeRange(start: CMTimeAdd(timeRange.start, .frame), duration: CMTimeSubtract(timeRange.duration, CMTimeMultiply(.frame, multiplier: 2)))
            }
            func clampTime(_ time: CMTime, toRange: CMTimeRange) -> CMTime {
                CMTimeMinimum(CMTimeMaximum(time, insetRange.start), insetRange.end)
            }
            let insetRange = insetTimeRange(CMTimeRange(start: asset.source.trackItem.startTime, duration: asset.source.trackItem.duration))
            let progress = clampTime(trim.progress, toRange: insetRange)

            func adjustedTrimSelectionTime(_ selectedTime: CMTime) -> CMTime {
                return clampTime(selectedTime, toRange: insetRange)
            }

            //print("[SELECTED_TIME] \(trim.selectedTime.debugDescription)\n[RANGE] \(trim.selectedRange.debugDescription)\n[PROGRESS] \(progress.debugDescription)\n[INSET_RANGE]\(insetRange.debugDescription)")
            guard let self = self else { return }
            switch event {
                
            case .didBeginTrimming:
                self.delegate?.view(self, didStartTrimming: asset, selectedTimeRange: trim.selectedRange, selectedTime: adjustedTrimSelectionTime(trim.selectedTime))
            case .selectedRangeChanged:
                self.delegate?.view(self, didContinueTrimming: asset, selectedTimeRange: trim.selectedRange, selectedTime: adjustedTrimSelectionTime(trim.selectedTime))
            case .didEndTrimming:
                self.delegate?.view(self, didEndTrimming: asset, selectedTimeRange: trim.selectedRange, selectedTime: adjustedTrimSelectionTime(trim.selectedTime))

            case .didBeginScrubbing:
                self.delegate?.view(self, didStartScrubbing: asset, selectedTimeRange: trim.selectedRange, selectedTime: progress)
            case .progressChanged:
                self.delegate?.view(self, didContinueScrubbing: asset, selectedTimeRange: trim.selectedRange, selectedTime: progress)
            case .didEndScrubbing:
                self.delegate?.view(self, didEndScrubbing: asset, selectedTimeRange: trim.selectedRange, selectedTime: progress)
            }
        }
    }
    
    private func stopTrimControlObservers(forCell cell: VideoTimelineCell) {
        cell.onTrimEvent = { _, _ in }
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
        guard let cell = collectionView.cellForItem(at: indexPath) as? VideoTimelineCell else {
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
    
    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
    }
    
    public func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
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
        cell.onCollapse = { [weak self] in
            guard let self = self else { return }
            self.collapseItems()
        }
        Task {
            do {
                cell.image = try await asset.thumbnail(size: collapsedCellSize)
            } catch {
                print("Error", error)
            }
        }
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
    private var interitemSpacing: CGFloat { 8.0 }
    private var expandedInteritemSpacing: CGFloat { 0.0 }
    private var expandedCellSize: CGSize { .init(width: collection.bounds.inset(by: .init(top: 0, left: 32, bottom: 0, right: 32)).width, height: collapsedCellSize.height) }
    private var collapsedCellSize: CGSize { .init(width: 72, height: 90) }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        indexPath == expandedIndexPath ? expandedCellSize : collapsedCellSize
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets { insets }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat { insets.top }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        expandedIndexPath.row == -1 ? interitemSpacing : expandedInteritemSpacing
    }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize { .zero }
    public func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForFooterInSection section: Int) -> CGSize { .zero }
}

internal class FlowLayout: UICollectionViewFlowLayout {
    public var expandedIndexPath = IndexPath(row: -1, section: 0)
    public init(scrollDirection: UICollectionView.ScrollDirection) {
        super.init()
        self.scrollDirection = scrollDirection
        NotificationCenter.default.addObserver(self, selector: #selector(handleOrientationChange(_:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Attributes
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        super.layoutAttributesForElements(in: rect)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        super.layoutAttributesForItem(at: indexPath)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        let attributes = super.initialLayoutAttributesForAppearingItem(at: itemIndexPath)
        attributes?.alpha = 1
        if expandedIndexPath.row == itemIndexPath.row {
            attributes?.zIndex = 100
        }
        return attributes
    }
    
    @objc private func handleOrientationChange(_ notification: Notification) {
        invalidateLayout()
    }
}

extension CMTime: CustomStringConvertible, CustomDebugStringConvertible {
    public var description: String {
        debugDescription
    }
    
    public var debugDescription: String {
        "\(seconds)"
    }
}

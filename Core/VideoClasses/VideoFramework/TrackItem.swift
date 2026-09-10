import VFCabbage
import AVFoundation
import Core

extension TrackItem {
    public func generatePlayerItem(size: CGSize = .zero, timeRange: CMTimeRange) -> AVPlayerItem? {
        let item = makeFullRangeCopy()
        item.resource.selectedTimeRange = timeRange
        item.startTime = CMTime.zero
        let timeline = Timeline()
        timeline.videoChannel = [item]
        timeline.audioChannel = [item]
        timeline.renderSize = size
        let generator = CompositionGenerator(timeline: timeline)
        let playerItem = generator.buildPlayerItem()
        return playerItem
    }
}

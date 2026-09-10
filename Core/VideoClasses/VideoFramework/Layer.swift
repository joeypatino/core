import AVKit
import VFCabbage
import Core

/// A layer represents a single video (or audio) clip, with a backing asset.
public class Layer: Codable {
    public var asset: Asset
    public var trackItem: TrackItem {
        asset.source.trackItem
    }
    public var timeRange: CMTimeRange {
        get { asset.timeRange }
        set { asset.timeRange = newValue }
    }
    
    public init(asset: Asset, transition: LayerTransition? = nil) {
        self.asset = asset
        self.trackItem.videoTransition = transition?.videoTransition
        self.trackItem.audioTransition = transition?.audioTransition
    }
    
    public init(asset: Asset, timeRange: CMTimeRange) {
        self.asset = asset
        self.timeRange = timeRange
    }
}

extension Layer: Equatable {
    public static func == (lhs: Layer, rhs: Layer) -> Bool {
        lhs.asset == rhs.asset
    }
}

extension Layer: TransitionableVideoProvider, TransitionableAudioProvider {
    public var videoTransition: VideoTransition? { trackItem.videoTransition }
    public var audioTransition: AudioTransition? { trackItem.audioTransition }
    public var duration: CMTime { trackItem.duration }
    public var startTime: CMTime {
        get { trackItem.startTime }
        set { trackItem.startTime = newValue }
    }

    public func applyEffect(to sourceImage: CIImage, at time: CMTime, renderSize: CGSize) -> CIImage {
        trackItem.applyEffect(to: sourceImage, at: time, renderSize: renderSize)
    }
    
    public func numberOfVideoTracks() -> Int {
        trackItem.numberOfVideoTracks()
    }
    
    public func numberOfAudioTracks() -> Int {
        trackItem.numberOfAudioTracks()
    }
    
    public func videoCompositionTrack(for composition: AVMutableComposition, at index: Int, preferredTrackID: Int32) -> AVCompositionTrack? {
        trackItem.videoCompositionTrack(for: composition, at: index, preferredTrackID: preferredTrackID)
    }
    
    public func audioCompositionTrack(for composition: AVMutableComposition, at index: Int, preferredTrackID: Int32) -> AVCompositionTrack? {
        trackItem.audioCompositionTrack(for: composition, at: index, preferredTrackID: preferredTrackID)
    }
    
    public func configure(audioMixParameters: AVMutableAudioMixInputParameters) {
        trackItem.configure(audioMixParameters: audioMixParameters)
    }
}

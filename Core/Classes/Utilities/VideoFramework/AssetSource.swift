import AVFoundation
import Photos
import VFCabbage

public class AssetSource {
    static let DEFAULT_TRANSITION_DURATION: CMTime = CMTime(seconds: 1, preferredTimescale: 600)
    
    public let resource: Resource
    public let trackItem: TrackItem
    public var selectedTimeRange: CMTimeRange {
        get { resource.selectedTimeRange }
        set { resource.selectedTimeRange = newValue }
    }
    
    public init(asset: AVAsset) {
        resource = AVAssetTrackResource(asset: asset)
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFit
        //trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        trackItem.audioTransition = FadeInOutAudioTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
    
    public init(asset: PHAsset) {
        resource = PHAssetImageResource(asset: asset, duration: Asset.DEFAULT_PHOTO_DURATION)
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFit
        //trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
}

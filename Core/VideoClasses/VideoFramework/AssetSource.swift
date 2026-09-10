import AVFoundation
import Photos
import VFCabbage
import Core

public class AssetSource {
    public static let DEFAULT_TRANSITION_DURATION: CMTime = CMTime(seconds: 1, preferredTimescale: 600)
    public static let TRANSITION_DURATION: Double = 1
    
    public let resource: Resource
    public let trackItem: TrackItem
    public var selectedTimeRange: CMTimeRange {
        get { resource.selectedTimeRange }
        set { resource.selectedTimeRange = newValue }
    }
    
    public init(asset: AVAsset) {
        resource = AVAssetTrackResource(asset: asset)
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFill
        trackItem.videoTransition = NoneTransition()
        trackItem.audioTransition = FadeInOutAudioTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
    
    public init(urlAsset: AVURLAsset) {
        resource = AVURLAssetTrackResource(asset: urlAsset)
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFill
        trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        trackItem.audioTransition = FadeInOutAudioTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }

    public init(asset: PHAsset) {
        switch asset.mediaType {
        case .video:
            resource = PHAssetTrackResource(phasset: asset)
        default:
            resource = PHAssetImageResource(asset: asset, duration: Asset.DEFAULT_PHOTO_DURATION)
        }
        
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFill
        trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
}

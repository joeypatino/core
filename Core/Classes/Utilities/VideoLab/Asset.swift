import PhotosUI
import AVKit
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
        trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        trackItem.audioTransition = FadeInOutAudioTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
    
    public init(asset: PHAsset) {
        resource = PHAssetImageResource(asset: asset, duration: Asset.DEFAULT_PHOTO_DURATION)
        trackItem = TrackItem(resource: resource)
        trackItem.videoConfiguration.contentMode = .aspectFit
        trackItem.videoTransition = CrossDissolveTransition(duration: AssetSource.DEFAULT_TRANSITION_DURATION)
        resource.prepare(completion: { _, _ in })
    }
}

/// An asset is a reprensetation of a video or audio source, based on a local file URL or PHAsset
public class Asset: Codable {
    static let DEFAULT_PHOTO_DURATION: CMTime = CMTime(seconds: 5, preferredTimescale: 600)
    
    public enum Error: Swift.Error, LocalizedError {
        case `internal`(Swift.Error)
        case imageDecoding
        case invalidEncoding
        case assetNotFound
    }
    public let url: URL?
    public let localAssetIdentifier: String?
    public var source: AssetSource
    public var duration: CMTime {
        if let asset = asset {
            return asset.duration
        } else if let _ = phasset {
            return Asset.DEFAULT_PHOTO_DURATION
        }
        return .zero
    }
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    public var mediaType: AVMediaType {
        if let asset = asset {
            return asset.tracks.first?.mediaType ?? .video
        } else {
            return .video
        }
    }
    public private(set) var asset: AVAsset? = nil {
        didSet {
            guard let asset = asset else { return }
            source = AssetSource(asset: asset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        }
    }
    public private(set) var phasset: PHAsset? = nil {
        didSet {
            guard let phasset = phasset else { return }
            source = AssetSource(asset: phasset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: Asset.DEFAULT_PHOTO_DURATION)
        }
    }

    public init(asset: PHAsset) {
        self.url = nil
        self.localAssetIdentifier = asset.localIdentifier
        self.phasset = asset
        self.source = AssetSource(asset: asset)
        self.timeRange = CMTimeRange(start: CMTime.zero, duration: Asset.DEFAULT_PHOTO_DURATION)
    }

    public init(url: URL) {
        self.localAssetIdentifier = nil
        self.url = url
        let avAsset = AVAsset(url: url)
        self.asset = avAsset
        self.source = AssetSource(asset: avAsset)
        self.timeRange = CMTimeRange(start: CMTime.zero, duration: avAsset.duration)
    }
    
    public func thumbnail(size: CGSize) async throws -> UIImage {
        if let asset = asset {
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.maximumSize = size
            imageGenerator.appliesPreferredTrackTransform = true
            imageGenerator.requestedTimeToleranceBefore = .zero
            imageGenerator.requestedTimeToleranceAfter = .zero
            return try await withCheckedThrowingContinuation { continuation in
                imageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: CMTime.zero)]) { requestedTime, cgImage, actualTime, result, error in
                    DispatchQueue.main.async {
                        if let error = error {
                            continuation.resume(with: .failure(Asset.Error.internal(error)))
                            return
                        }
                        guard let cgImage1 = cgImage else {
                            continuation.resume(with: .failure(Asset.Error.imageDecoding))
                            return
                        }
                        let image = UIImage(cgImage: cgImage1)
                        continuation.resume(with: .success(image))
                    }
                }
            }
        }
        else if let _ = phasset {
            guard let ciImage = source.resource.image(at: .zero, renderSize: size) else {
                throw Asset.Error.imageDecoding
            }
            return UIImage(ciImage: ciImage)
        }
        throw Asset.Error.imageDecoding
    }
    
    public func trim(_ timeRange: CMTimeRange) {
        do {
            asset = try asset?.trim(toRange: timeRange)
        } catch {
            // handle error
            print(error)
        }
    }
    
    // Coding
    public enum CodingKeys: String, CodingKey {
        case url
        case localAssetIdentifier
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let encodedUrl = try? values.decode(URL.self, forKey: .url) {
            let name = encodedUrl.lastPathComponent
            self.url = FileManager.default.cachesDirectory.appendingPathComponent(name)
            guard let url = url else { throw Asset.Error.invalidEncoding }
            let avAsset = AVAsset(url: url)
            self.localAssetIdentifier = nil
            self.asset = avAsset
            self.source = AssetSource(asset: avAsset)
            self.timeRange = CMTimeRange(start: CMTime.zero, duration: avAsset.duration)
        } else if let localAssetIdentifier = try? values.decode(String.self, forKey: .localAssetIdentifier) {
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [localAssetIdentifier], options: PHFetchOptions())
            guard let asset = results.firstObject else { throw Asset.Error.assetNotFound }
            self.url = nil
            self.localAssetIdentifier = localAssetIdentifier
            self.phasset = asset
            self.source = AssetSource(asset: asset)
            self.timeRange = CMTimeRange(start: CMTime.zero, duration: Asset.DEFAULT_PHOTO_DURATION)
        } else {
            throw Asset.Error.invalidEncoding
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        lhs.asset == rhs.asset
    }
}

public extension AVAsset {
    var mediaType: AVMediaType { tracks.first?.mediaType ?? .muxed }
    func trim(toRange range: CMTimeRange) throws -> AVAsset {
        guard CMTimeRangeEqual(CMTimeRange(start: .zero, duration: duration), range) == false else {
            return self
        }
        
        let composition = AVMutableComposition()
        try composition.insertTimeRange(range, of: self, at: .zero)
        if let videoTrack = tracks(withMediaType: .video).first {
            composition.tracks.forEach {$0.preferredTransform = videoTrack.preferredTransform}
        }
        return composition
    }
}

extension AVMediaType: CustomDebugStringConvertible {
    public var debugDescription: String {
        switch self {
        case .video: return "video"
        case .audio: return "audio"
        case .text: return "text"
        case .closedCaption: return "closedCaption"
        default:
            return "\(self.rawValue)"
        }
    }
}

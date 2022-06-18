import VideoLab
import AVKit

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

/// An asset is a reprensetation of a video or audio source, based on a local file URL
public class Asset: Codable {
    public enum Error: Swift.Error, LocalizedError {
        case `internal`(Swift.Error)
        case imageDecoding
    }
    public let url: URL
    public var source: AVAssetSource
    public var duration: CMTime { asset.duration }
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    public var mediaType: AVMediaType {
        asset.tracks.first?.mediaType ?? .video
    }
    public private(set) var asset: AVAsset {
        didSet {
            source = AVAssetSource(asset: asset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        }
    }
    public init(url: URL) {
        self.url = url
        self.asset = AVAsset(url: url)
        self.source = AVAssetSource(asset: asset)
        self.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
    }
    
    public func thumbnail(size: CGSize) async throws -> UIImage {
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
    
    public func trim(_ timeRange: CMTimeRange) {
        do {
            asset = try asset.trim(toRange: timeRange)
        } catch {
            // handle error
            print(error)
        }
    }
    
    // Coding
    public enum CodingKeys: String, CodingKey {
        case url
    }
    
    public required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        let encodedUrl = try values.decode(URL.self, forKey: .url)
        let name = encodedUrl.lastPathComponent
        url = FileManager.default.cachesDirectory.appendingPathComponent(name)
        self.asset = AVAsset(url: url)
        self.source = AVAssetSource(asset: asset)
        self.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
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

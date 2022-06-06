import VideoLab
import AVKit

/// An asset is a reprensetation of a video or audio source, based on a local file URL
public class Asset: Codable {
    public enum Error: Swift.Error, LocalizedError {
        case `internal`(Swift.Error)
        case imageDecoding
    }
    public let url: URL
    public let source: AVAssetSource
    public var duration: CMTime { asset.duration }
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    
    private let asset: AVAsset
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

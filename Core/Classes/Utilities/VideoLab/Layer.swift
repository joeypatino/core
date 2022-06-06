import VideoLab
import AVKit

/// A layer represents a single video (or audio) clip, with a backing asset.
/// It has a start, end and durations
public class Layer: Codable {
    public var asset: Asset
    public var timeRange: CMTimeRange {
        get { asset.timeRange }
        set { asset.timeRange = newValue }
    }
    
    public init(asset: Asset) {
        self.asset = asset
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

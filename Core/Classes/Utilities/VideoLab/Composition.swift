import VideoLab
import AVKit

/// Composition represents the entire video composition. It contains all of the video
/// clips (layers) and properties about them.
public class Composition: Codable {
    public var renderSize = CGSize(width: 720, height: 1280)
    public var playerItem: AVPlayerItem { videoLab.makePlayerItem() }
    public var imageGenerator: AVAssetImageGenerator { videoLab.makeImageGenerator() }
    public private(set) var layers: [Layer]
    public private(set) var audioLayers: [Layer]
    
    private var videoLab: VideoLab
    private let renderComposition: RenderComposition
    public init(layers: [Layer] = []) {
        self.layers = layers
        self.audioLayers = []
        self.renderComposition = RenderComposition()
        self.videoLab = VideoLab(renderComposition: renderComposition)
    }
    
    public func append(layerWithAsset asset: Asset) {
        defer {
            renderComposition.addLayer(with: asset.asset)
            videoLab = VideoLab(renderComposition: renderComposition)
        }
        asset.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let timeRange = asset.timeRange
        layers.append(Layer(asset: asset, timeRange: timeRange))
    }
    
    public func insert(layerWithAsset asset: Asset, at index: Int) {
        insert(Layer(asset: Asset(url: asset.url)), at: index)
    }
    
    public func append(layerWithUrl url: URL) {
        let asset = Asset(url: url)
        append(layerWithAsset: asset)
    }
    
    public func insert(layerWithUrl url: URL, at index: Int) {
        let asset = Asset(url: url)
        insert(layerWithAsset: asset, at: index)
    }
    
    public func append(_ layer: Layer) {
        defer {
            renderComposition.addLayer(with: layer.asset.asset)
            videoLab = VideoLab(renderComposition: renderComposition)
        }
        var timeRange = layer.asset.timeRange
        if let lastLayer = layers.last {
            timeRange.start = CMTimeRangeGetEnd(lastLayer.asset.timeRange)
            layer.asset.timeRange = timeRange
            layers.append(layer)
        } else {
            timeRange.start = .zero
            layer.asset.timeRange = timeRange
            layers.append(layer)
        }
    }
    
    public func insert(_ layer: Layer, at index: Int) {
        defer {
            renderComposition.insertLayer(with: layer.asset.asset, at: index)
            videoLab = VideoLab(renderComposition: renderComposition)
        }
        layers.insert(layer, at: index)
        sequence()
    }
    
    public func setAudio(layerWithAsset asset: Asset, timeRange: CMTimeRange) {
        let trimmedAsset = asset
        trimmedAsset.trim(timeRange)
        let layer = Layer(asset: trimmedAsset)
        audioLayers.append(layer)
        renderComposition.addLayer(RenderLayer(asset: layer.asset.asset))
    }
    
    @discardableResult
    public func exchange(layerAt sourceIndex: Int, with destinationIndex: Int) -> Bool {
        guard layers.count-1 >= sourceIndex else { return false }
        
        var sindex = sourceIndex
        let dindex = destinationIndex

        sequence()
        // grab a copy of the source layer
        let layer = layers[sindex]
        // insert it first
        insert(layer, at: dindex)
        // update the destination index if needed
        if sindex >= dindex { sindex += 1 }
        // then remove it
        if let _ = remove(layerAt: sindex) {
            sequence()
            return true
        }
        // failure, revert insertion
        remove(layerAt: dindex)
        
        return false
    }
    
    @discardableResult
    public func remove(layerAt index: Int) -> Layer? {
        defer {
            renderComposition.removeLayer(at: index)
            videoLab = VideoLab(renderComposition: renderComposition)
        }
        if layers.isEmpty { return nil }
        let layer = layers.remove(at: index)
        sequence()
        return layer
    }
    
    private func sequence() {
        for i in 0..<layers.count {
            let layer = layers[i]
            layer.timeRange = CMTimeRange(start: .zero, duration: layer.asset.duration)
        }

        let staringIdx = 1
        let endingIdx = layers.count
        var previousLayer = layers[0]
        var timeRange = previousLayer.timeRange
        timeRange.start = CMTime.zero
        previousLayer.timeRange = timeRange

        for i in staringIdx..<endingIdx {
            let layer = layers[i]
            timeRange = layer.timeRange
            timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
            layer.timeRange = timeRange
            previousLayer = layer
        }
        //print(layers.map { ($0.timeRange.start.seconds, $0.timeRange.end.seconds, $0.timeRange.duration.seconds, $0.asset.mediaType) })
    }
    
    public func startTime(forAsset asset: Asset) -> CMTime {
        timeRange(forAsset: asset).start
    }

    public func timeRange(forAsset asset: Asset) -> CMTimeRange {
        guard let index = layers.map({ $0.asset }).firstIndex(of: asset) else { return .zero }
        let sequenced = sequencedAssets()
        return sequenced[index]
    }
    
    private func sequencedAssets(types: [AVMediaType] = [.video]) -> [CMTimeRange] {
        let assets = layers.map { $0.asset }.filter { types.contains($0.mediaType) }
        var offset = CMTime.zero
        return assets.map { asset -> CMTimeRange in
            let time = asset.timeRange
            let range = CMTimeRange(start: offset, duration: time.duration)
            offset = CMTimeAdd(offset, time.duration)
            return range
        }
    }
    
    // Coding
    public enum CodingKeys: String, CodingKey {
        case renderSize
        case layers
        case audioLayers
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        renderComposition = RenderComposition()
        videoLab = VideoLab(renderComposition: renderComposition)
        renderSize = try values.decode(CGSize.self, forKey: .renderSize)
        layers = try values.decode([Layer].self, forKey: .layers)
        audioLayers = try values.decode([Layer].self, forKey: .audioLayers)
        layers.forEach { renderComposition.addLayer(with: $0.asset.asset )}
        audioLayers.forEach { renderComposition.addLayer(with: $0.asset.asset )}
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(renderSize, forKey: .renderSize)
        try container.encode(layers, forKey: .layers)
    }
}

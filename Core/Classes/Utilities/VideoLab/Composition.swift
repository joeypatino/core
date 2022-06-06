import VideoLab
import AVKit

/// Composition represents the entire video composition. It contains all of the video
/// clips (layers) and properties about them.
public class Composition: Codable {
    public var renderSize = CGSize(width: 720, height: 1280)
    public var playerItem: AVPlayerItem { videoLab.makePlayerItem() }
    public var thumbnailGenerator: AVAssetImageGenerator { videoLab.makeImageGenerator() }
    public private(set) var layers: [Layer]
    
    private var videoLab: VideoLab
    private let composition: RenderComposition
    public init(layers: [Layer] = []) {
        self.layers = layers
        self.composition = RenderComposition()
        self.videoLab = VideoLab(renderComposition: composition)
    }
    
    public func append(layerWithAsset asset: Asset) {
        defer {
            composition.addLayer(with: AVAsset(url: asset.url))
            videoLab = VideoLab(renderComposition: composition)
        }
        asset.timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        let timeRange = asset.timeRange
        let layer = Layer(asset: asset, timeRange: timeRange)
        layers.append(layer)
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
            composition.addLayer(with: AVAsset(url: layer.asset.url))
            videoLab = VideoLab(renderComposition: composition)
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
            composition.insertLayer(with: AVAsset(url: layer.asset.url), at: index)
            videoLab = VideoLab(renderComposition: composition)
        }
        layers.insert(layer, at: index)
        
        // compact down first....
        for i in 0..<layers.count {
            let layer = layers[i]
            layer.timeRange = CMTimeRange(start: .zero, duration: layer.asset.duration)
        }

        var previousLayer = layers[0]
        var timeRange = previousLayer.timeRange
        timeRange.start = CMTime.zero
        previousLayer.timeRange = timeRange
        
        let staringIdx = 1
        let endingIdx = layers.count
        
        for i in staringIdx..<endingIdx {
            let layer = layers[i]
            timeRange = layer.timeRange
            timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
            layer.timeRange = timeRange
            previousLayer = layer
        }
    }
    
    @discardableResult
    public func exchange(layerAt sourceIndex: Int, with destinationIndex: Int) -> Bool {
        guard layers.count-1 >= sourceIndex else { return false }
        func layout() {
            
            // compact down first....
            for i in 0..<layers.count {
                let layer = layers[i]
                layer.timeRange = CMTimeRange(start: .zero, duration: layer.asset.duration)
            }
        }
        
        var sindex = sourceIndex
        let dindex = destinationIndex
        
        // grab a copy of the source layer
        let layer = layers[sindex]
        // insert it first
        insert(layer, at: dindex)
        // update the destination index if needed
        if sindex >= dindex { sindex += 1 }
        // then remove it
        if let _ = remove(layerAt: sindex) {
            layout()
            return true
        }
        // failure, revert insertion
        remove(layerAt: dindex)
        
        return false
    }
    
    @discardableResult
    public func remove(layerAt index: Int) -> Layer? {
        defer {
            composition.removeLayer(at: index)
            videoLab = VideoLab(renderComposition: composition)
        }
        if layers.isEmpty { return nil }
        let layer = layers.remove(at: index)
        if layers.isEmpty { return layer }
        
        // compact down first....
        for i in 0..<layers.count {
            let layer = layers[i]
            layer.timeRange = CMTimeRange(start: .zero, duration: layer.asset.duration)
        }

        let staringIdx = index
        let endingIdx = layers.count
        
        if index > 0 {
            var previousLayer = layers[index-1]
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
        } else {
            var previousLayer: Layer?
            var timeRange = CMTimeRange.zero
            for i in staringIdx..<endingIdx {
                let layer = layers[i]
                timeRange = layer.timeRange
                timeRange.start = previousLayer.map { CMTimeRangeGetEnd($0.timeRange) } ?? .zero
                layer.timeRange = timeRange
                previousLayer = layer
            }
        }
        
        return layer
    }
    
    public func timeRange(forAsset asset: Asset) -> CMTimeRange {
        let assets = layers.map { $0.asset }
        guard let index = assets.firstIndex(of: asset) else { return .zero }
        var offset = CMTime.zero
        let sequenced = assets.map { asset -> CMTimeRange in
            let time = asset.timeRange
            let range = CMTimeRange(start: offset, duration: time.duration)
            offset = CMTimeAdd(offset, time.duration)
            return range
        }
        print(sequenced)
        return sequenced[index]
    }
    
    // Coding
    public enum CodingKeys: String, CodingKey {
        case renderSize
        case layers
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        composition = RenderComposition()
        videoLab = VideoLab(renderComposition: composition)
        renderSize = try values.decode(CGSize.self, forKey: .renderSize)
        layers = try values.decode([Layer].self, forKey: .layers)
        layers.forEach { composition.addLayer(with: AVAsset(url: $0.asset.url) )}
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(renderSize, forKey: .renderSize)
        try container.encode(layers, forKey: .layers)
    }
}

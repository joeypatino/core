import AVKit
import VFCabbage

/// Composition represents the entire video composition. It contains all of the video
/// clips (videoLayers) and properties about them.
public class Composition: Codable {
    public var renderSize: CGSize
    public var playerItem: AVPlayerItem {
        CompositionGenerator(timeline: timeline).buildPlayerItem()
    }
    public var imageGenerator: AVAssetImageGenerator {
        CompositionGenerator(timeline: timeline).buildImageGenerator()
    }
    public private(set) var videoLayers: [Layer] {
        didSet { timeline.videoChannel = videoLayers.map { $0.asset.source.trackItem } }
    }
    public private(set) var audioLayers: [Layer] {
        didSet { timeline.audioChannel = audioLayers.map { $0.asset.source.trackItem } }
    }
    
    private let timeline = Timeline()
    
    public init(videoLayers: [Layer] = [], audioLayers: [Layer] = [], renderSize: CGSize = CGSize(width: 1080, height: 1920)) {
        self.videoLayers = videoLayers
        self.audioLayers = audioLayers
        self.renderSize = renderSize
        timeline.renderSize = renderSize
        timeline.videoChannel = videoLayers.map { $0.asset.source.trackItem }
        timeline.audioChannel = audioLayers.map { $0.asset.source.trackItem }
        
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        } catch {
            print("Error", error)
        }
    }

    public func append(layerWithAsset asset: Asset) {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        videoLayers.append(Layer(asset: asset, timeRange: asset.timeRange))
    }
    
    public func insert(layerWithAsset asset: Asset, at index: Int) {
        insert(Layer(asset: asset), at: index)
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
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        var timeRange = layer.asset.timeRange
        if let lastLayer = videoLayers.last {
            timeRange.start = CMTimeRangeGetEnd(lastLayer.asset.timeRange)
            layer.asset.timeRange = timeRange
            videoLayers.append(layer)
        } else {
            timeRange.start = .zero
            layer.asset.timeRange = timeRange
            videoLayers.append(layer)
        }
    }
    
    public func insert(_ layer: Layer, at index: Int) {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        videoLayers.insert(layer, at: index)
    }
    
    @discardableResult
    public func exchange(layerAt sourceIndex: Int, with destinationIndex: Int) -> Bool {
        guard videoLayers.count-1 >= sourceIndex else { return false }
        var sindex = sourceIndex
        var dindex = destinationIndex
        
        // the layer we're moving
        let layer = videoLayers[sindex]
        
        // update the destination index if needed
        if dindex >= sindex { dindex += 1 }
        
        // insert the layer to the destination
        insert(layer, at: dindex)
        
        // update the source index if needed
        if sindex >= dindex { sindex += 1 }
        
        // remove the original source layer
        if let _ = remove(layerAt: sindex) {
            return true
        }
        // on failure revert insertion
        remove(layerAt: dindex)
        
        return false
    }
    
    @discardableResult
    public func remove(layerAt index: Int) -> Layer? {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        if videoLayers.isEmpty { return nil }
        let layer = videoLayers.remove(at: index)
        return layer
    }
    
    // MARK: Private
    
    private func didUpdateVideoLayers() {
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        } catch {
            print("Error", error)
        }
    }
    
    private func didUpdateAudioLayers() {
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
        } catch {
            print("Error", error)
        }
    }
    
//    public func setAudio(layerWithAsset asset: Asset, timeRange: CMTimeRange) {
//        let trimmedAsset = asset
//        trimmedAsset.trim(timeRange)
//        let layer = Layer(asset: trimmedAsset)
//        audioLayers.append(layer)
//        renderComposition.addLayer(RenderLayer(asset: layer.asset.asset))
//    }
//
//    private func sequence() {
//        for i in 0..<videoLayers.count {
//            let layer = videoLayers[i]
//            layer.timeRange = CMTimeRange(start: .zero, duration: layer.asset.duration)
//        }
//
//        let staringIdx = 1
//        let endingIdx = videoLayers.count
//        var previousLayer = videoLayers[0]
//        var timeRange = previousLayer.timeRange
//        timeRange.start = CMTime.zero
//        previousLayer.timeRange = timeRange
//
//        for i in staringIdx..<endingIdx {
//            let layer = videoLayers[i]
//            timeRange = layer.timeRange
//            timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
//            layer.timeRange = timeRange
//            previousLayer = layer
//        }
//        //print(videoLayers.map { ($0.timeRange.start.seconds, $0.timeRange.end.seconds, $0.timeRange.duration.seconds, $0.asset.mediaType) })
//    }
//
//    public func startTime(forAsset asset: Asset) -> CMTime {
//        timeRange(forAsset: asset).start
//    }
//
//    public func timeRange(forAsset asset: Asset) -> CMTimeRange {
//        guard let index = videoLayers.map({ $0.asset }).firstIndex(of: asset) else { return .zero }
//        let sequenced = sequencedAssets()
//        return sequenced[index]
//    }
//
//    private func sequencedAssets(types: [AVMediaType] = [.video]) -> [CMTimeRange] {
//        let assets = videoLayers.map { $0.asset }.filter { types.contains($0.mediaType) }
//        var offset = CMTime.zero
//        return assets.map { asset -> CMTimeRange in
//            let time = asset.timeRange
//            let range = CMTimeRange(start: offset, duration: time.duration)
//            offset = CMTimeAdd(offset, time.duration)
//            return range
//        }
//    }

    // Coding
    public enum CodingKeys: String, CodingKey {
        case renderSize
        case videoLayers
        case audioLayers
    }
    
    required public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        renderSize = try values.decode(CGSize.self, forKey: .renderSize)
        videoLayers = try values.decode([Layer].self, forKey: .videoLayers)
        audioLayers = try values.decode([Layer].self, forKey: .audioLayers)
        timeline.renderSize = renderSize
        timeline.videoChannel = videoLayers.map { $0.asset.source.trackItem }
        timeline.audioChannel = audioLayers.map { $0.asset.source.trackItem }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(renderSize, forKey: .renderSize)
        try container.encode(videoLayers, forKey: .videoLayers)
        try container.encode(audioLayers, forKey: .audioLayers)
    }
}

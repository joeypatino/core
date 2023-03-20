import AVKit
import VFCabbage

public protocol LayerTransition {
    static var none: LayerTransition { get }
    
    var videoTransition: NoneTransition? { get }
    var audioTransition: AudioTransition? { get }
}

public enum VideoLayerTransition: LayerTransition {
    public static var none: LayerTransition = VideoLayerTransition.caseNone
    
    case caseNone
    case crossDissolve(duration: Double)
    
    var transition: NoneTransition {
        switch self {
        case .caseNone:
            return NoneTransition()
        case .crossDissolve(let duration):
            return CrossDissolveTransition(duration: CMTime(seconds: duration, preferredTimescale: 600))
        }
    }
    
    public var videoTransition: NoneTransition? { transition }
    public var audioTransition: AudioTransition? { nil }
}

public enum AudioLayerTransition: LayerTransition {
    public static var none: LayerTransition = AudioLayerTransition.caseNone
    
    case caseNone
    case fadeInOut(duration: Double)
    
    var transition: AudioTransition {
        switch self {
        case .caseNone:
            return FadeInOutAudioTransition(duration: CMTime(seconds: 0, preferredTimescale: 600))
        case .fadeInOut(let duration):
            return FadeInOutAudioTransition(duration: CMTime(seconds: duration, preferredTimescale: 600))
        }
    }
    
    public var videoTransition: NoneTransition? { nil }
    public var audioTransition: AudioTransition? { transition }
}

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
    public var exportSession: AVAssetExportSession {
        CompositionGenerator(timeline: timeline).buildExportSession(presetName: AVAssetExportPresetHighestQuality, outputDirectory: FileManager.default.cachesDirectory)!
    }
    public private(set) var videoLayers: [Layer] {
        didSet { timeline.videoChannel = videoLayers.map { $0.asset.source.trackItem } }
    }
    public private(set) var audioLayers: [Layer] {
        didSet { timeline.audioChannel = audioLayers.map { $0.asset.source.trackItem } }
    }
    
    private let timeline = Timeline()
    public var backgroundAudio: AVAsset? {
        didSet { updateBackgroundAudio() }
    }
    
    private var _backgroundAudioTrack: TrackItem = TrackItem(resource: Resource())
    public var backgroundAudioConfiguration: AudioConfiguration {
        _backgroundAudioTrack.audioConfiguration
    }
    
    private var _audioTrack: TrackItem = TrackItem(resource: Resource())
    public var audioConfiguration: AudioConfiguration {
        _audioTrack.audioConfiguration
    }
    public func setAudioVolume(_ volume: Float) {
        audioConfiguration.volume = volume
        audioLayers.forEach { $0.trackItem.audioConfiguration.volume = volume }
        videoLayers.forEach { $0.trackItem.audioConfiguration.volume = volume }
        didUpdateVideoLayers()
    }
    
    public init(videoLayers: [Layer] = [], audioLayers: [Layer] = [], renderSize: CGSize = CGSize(width: 1080, height: 1920)) {
        self.videoLayers = videoLayers
        self.audioLayers = audioLayers
        self.renderSize = renderSize
        timeline.renderSize = renderSize
        timeline.videoChannel = videoLayers.map { $0.asset.source.trackItem }
        timeline.audioChannel = audioLayers.map { $0.asset.source.trackItem }
        timeline.audios = [_backgroundAudioTrack]
        didUpdateVideoLayers()
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
    
    public func insertAudio(layerWithAsset asset: Asset, at index: Int) {
        insertAudio(Layer(asset: asset), at: index)
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
        videoLayers.append(layer)
        audioLayers.append(layer)
    }
    
    public func insert(_ layer: Layer, at index: Int) {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        videoLayers.insert(layer, at: index)
    }
    
    public func insertAudio(_ layer: Layer, at index: Int) {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        audioLayers.insert(layer, at: index)
    }
    
    @discardableResult
    public func exchange(layerAt sourceIndex: Int, with destinationIndex: Int) -> Bool {
        guard videoLayers.count-1 >= sourceIndex else { print("return false"); return false }
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
        return remove(layerAt: sindex) != nil
    }
    
    @discardableResult
    public func remove(layerAt index: Int) -> Layer? {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        if videoLayers.isEmpty { return nil }
        if index >= videoLayers.count { return nil }
        return videoLayers.remove(at: index)
    }

    @discardableResult
    public func removeAudio(layerAt index: Int) -> Layer? {
        defer {
            didUpdateVideoLayers()
            didUpdateAudioLayers()
        }
        if audioLayers.isEmpty { return nil }
        if index >= audioLayers.count { return nil }
        return audioLayers.remove(at: index)
    }
    
    public func reload() {
        didUpdateVideoLayers()
        didUpdateAudioLayers()
    }
    
    // MARK: Private
    
    private func updateBackgroundAudio() {
        if let asset = backgroundAudio {
            _backgroundAudioTrack.resource = AVAssetTrackResource(asset: asset)
            _backgroundAudioTrack.resource.selectedTimeRange = CMTimeRange(start: .zero, end: timeline.videoChannel.last?.timeRange.end ?? .zero)
//            print("playerItem.duration", playerItem.duration)
//            print("_backgroundAudioTrack", _backgroundAudioTrack.duration)
//            print("videoChannel", timeline.videoChannel.last?.timeRange.end ?? .zero)
            timeline.audios = [_backgroundAudioTrack]
        } else {
            timeline.audios = []
        }
    }
    
    private func didUpdateVideoLayers() {
        do {
            try Timeline.reloadVideoStartTime(providers: timeline.videoChannel)
            updateBackgroundAudio()
        } catch {
            print("Error", error)
        }
    }
    
    private func didUpdateAudioLayers() {
//        do {
//            try Timeline.reloadAudioStartTime(providers: timeline.audioChannel)
//            updateBackgroundAudio()
//        } catch {
//            print("Error", error)
//        }
    }

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
        
        didUpdateVideoLayers()
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(renderSize, forKey: .renderSize)
        try container.encode(videoLayers, forKey: .videoLayers)
        try container.encode(audioLayers, forKey: .audioLayers)
    }
}

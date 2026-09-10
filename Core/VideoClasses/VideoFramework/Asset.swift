import PhotosUI
import AVKit
import AVFoundation
import UIKit
import Core

public enum Asset: Codable {
    static let DEFAULT_PHOTO_DURATION: CMTime = CMTime(seconds: 5, preferredTimescale: 600)
    
    case localFile(LocalFileAsset)
    case photoLibrary(PhotosLibraryAsset)
    case asset(AVURLAssetAsset)
    
    public var identifier: String {
        source.trackItem.identifier
    }
    public var source: AssetSource {
        switch self {
        case .localFile(let asset):
            return asset.source
        case .photoLibrary(let asset):
            return asset.source
        case .asset(let asset):
            return asset.source
        }
    }
    public var duration: CMTime {
        switch self {
        case .localFile(let asset):
            return asset.duration
        case .photoLibrary(let asset):
            return asset.duration
        case .asset(let asset):
            return asset.duration
        }
    }
    public var originalTime: CMTimeRange {
        get {
            switch self {
            case .localFile(let asset):
                return asset.originalTime
            case .photoLibrary(let asset):
                return asset.originalTime
            case .asset(let asset):
                return asset.originalTime
            }
        }
        set {
            switch self {
            case .localFile(var asset):
                asset.originalTime = newValue
            case .photoLibrary(var asset):
                asset.originalTime = newValue
            case .asset(var asset):
                asset.originalTime = newValue
            }
        }
    }
    public var timeRange: CMTimeRange {
        get {
            switch self {
            case .localFile(let asset):
                return asset.timeRange
            case .photoLibrary(let asset):
                return asset.timeRange
            case .asset(let asset):
                return asset.timeRange
            }
        }
        set {
            switch self {
            case .localFile(var asset):
                asset.timeRange = newValue
            case .photoLibrary(var asset):
                asset.timeRange = newValue
            case .asset(var asset):
                asset.timeRange = newValue
            }
        }
    }
    public var mediaType: AVMediaType {
        switch self {
        case .localFile(let asset):
            return asset.mediaType
        case .photoLibrary(let asset):
            return asset.mediaType
        case .asset(let asset):
            return asset.mediaType
        }
    }
    public var timeRangeInTimeline: CMTimeRange { source.trackItem.timeRange }
    public func thumbnail(size: CGSize) async throws -> UIImage {
        switch self {
        case .localFile(let asset):
            return try await asset.thumbnail(size: size)
        case .photoLibrary(let asset):
            return try await asset.thumbnail(size: size)
        case .asset(let asset):
            return try await asset.thumbnail(size: size)
        }
    }
    
    public init(url: URL) {
        self = .localFile(LocalFileAsset(url: url))
    }
    
    public init(asset: PHAsset) {
        self = .photoLibrary(PhotosLibraryAsset(asset: asset))
    }
    
    public init(asset: AVURLAsset) {
        self = .asset(AVURLAssetAsset(asset: asset))
    }
    
    public enum Kind: String, Codable {
        case localFile
        case photosLibrary
        case asset
    }
    
    public enum Error: Swift.Error, LocalizedError {
        case `internal`(Swift.Error)
        case imageDecoding
        case invalidEncoding
        case assetNotFound
    }
    
    public enum CodingKeys: String, CodingKey {
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(Asset.Kind.self, forKey: .type)
        switch type {
        case .localFile:
            self = .localFile(try decoder.singleValueContainer().decode(LocalFileAsset.self))
        case .photosLibrary:
            self = .photoLibrary(try decoder.singleValueContainer().decode(PhotosLibraryAsset.self))
        case .asset:
            self = .asset(try decoder.singleValueContainer().decode(AVURLAssetAsset.self))
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .localFile(let component):
            try container.encode(component)
        case .photoLibrary(let component):
            try container.encode(component)
        case .asset(let component):
            try container.encode(component)
        }
    }
}

// MARK: - ""NSCopying"" support
extension Asset {
    public func duplicate() -> Asset {
        switch self {
        case .localFile(let asset):
            var copy = type(of: self).init(url: asset.url)
            copy.source.trackItem.identifier = self.identifier
            copy.source.selectedTimeRange = self.source.selectedTimeRange
            copy.originalTime = self.originalTime
            return copy
        case .photoLibrary(let asset):
            var copy = type(of: self).init(asset: asset.asset)
            copy.source.trackItem.identifier = self.identifier
            copy.source.selectedTimeRange = self.source.selectedTimeRange
            copy.originalTime = self.originalTime
            return copy
        case .asset(let asset):
            var copy = type(of: self).init(asset: asset.asset)
            copy.source.trackItem.identifier = self.identifier
            copy.source.selectedTimeRange = self.source.selectedTimeRange
            copy.originalTime = self.originalTime
            return copy
        }
    }
}

public struct LocalFileAsset: Codable {
    public let type: Asset.Kind
    public let url: URL
    public var source: AssetSource
    public var duration: CMTime { asset.duration }
    public var originalTime: CMTimeRange
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    public var mediaType: AVMediaType { asset.tracks.first?.mediaType ?? .video }
    public private(set) var asset: AVAsset {
        didSet {
            source = AssetSource(asset: asset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
        }
    }
    
    public init(url: URL) {
        self.type = .localFile
        self.url = url
        let avAsset = AVAsset(url: url)
        self.asset = avAsset
        self.source = AssetSource(asset: avAsset)
        self.originalTime = CMTimeRange(start: .zero, duration: avAsset.duration)
        self.timeRange = CMTimeRange(start: CMTime.zero, duration: avAsset.duration)
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
    
    public enum CodingKeys: String, CodingKey {
        case url
        case timeRange
        case originalTime
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let encodedUrl = try? values.decode(URL.self, forKey: .url) {
            let name = encodedUrl.lastPathComponent
            self.type = .localFile
            self.url = FileManager.default.cachesDirectory.appendingPathComponent(name)
            self.asset = AVAsset(url: url)
            self.source = AssetSource(asset: asset)
            self.originalTime = try values.decode(CMTimeRange.self, forKey: .originalTime)
            self.timeRange = try values.decode(CMTimeRange.self, forKey: .timeRange)
        } else {
            throw Asset.Error.invalidEncoding
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(originalTime, forKey: .originalTime)
        try container.encode(type, forKey: .type)
    }
}

public struct PhotosLibraryAsset: Codable {
    public let type: Asset.Kind
    public let localIdentifier: String
    public var source: AssetSource
    public var duration: CMTime {
        source.selectedTimeRange.duration
    }
    public var originalTime: CMTimeRange
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    public var mediaType: AVMediaType { .video }
    public private(set) var asset: PHAsset {
        didSet {
            source = AssetSource(asset: asset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: source.selectedTimeRange.duration)
        }
    }
    
    public init(asset: PHAsset) {
        self.type = .photosLibrary
        self.localIdentifier = asset.localIdentifier
        self.asset = asset
        self.source = AssetSource(asset: asset)
        self.originalTime = CMTimeRange(start: .zero, duration: source.selectedTimeRange.duration)
        self.timeRange = source.selectedTimeRange
    }
    
    public func thumbnail(size: CGSize) async throws -> UIImage {
        guard let ciImage = source.resource.image(at: .zero, renderSize: size) else {
            throw Asset.Error.imageDecoding
        }
        return UIImage(ciImage: ciImage)
    }
    
    public enum CodingKeys: String, CodingKey {
        case localIdentifier
        case timeRange
        case originalTime
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        if let localIdentifier = try? values.decode(String.self, forKey: .localIdentifier) {
            let results = PHAsset.fetchAssets(withLocalIdentifiers: [localIdentifier], options: PHFetchOptions())
            guard let asset = results.firstObject else { throw Asset.Error.assetNotFound }
            self.type = .photosLibrary
            self.localIdentifier = localIdentifier
            self.asset = asset
            self.source = AssetSource(asset: asset)
            self.originalTime = try values.decode(CMTimeRange.self, forKey: .originalTime)
            self.timeRange = try values.decode(CMTimeRange.self, forKey: .timeRange)
        } else {
            throw Asset.Error.invalidEncoding
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(localIdentifier, forKey: .localIdentifier)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(originalTime, forKey: .originalTime)
        try container.encode(type, forKey: .type)
    }
}

public struct AVURLAssetAsset: Codable {
    public let type: Asset.Kind
    public let url: URL
    public var source: AssetSource
    public var duration: CMTime {
        source.selectedTimeRange.duration
    }
    public var originalTime: CMTimeRange
    public var timeRange: CMTimeRange {
        get { source.selectedTimeRange }
        set { source.selectedTimeRange = newValue }
    }
    public var mediaType: AVMediaType { .video }
    public private(set) var asset: AVURLAsset {
        didSet {
            source = AssetSource(urlAsset: asset)
            timeRange = CMTimeRange(start: CMTime.zero, duration: source.selectedTimeRange.duration)
        }
    }
    
    public init(asset: AVURLAsset) {
        self.type = .asset
        self.url = asset.url
        self.asset = asset
        self.source = AssetSource(urlAsset: asset)
        self.originalTime = CMTimeRange(start: .zero, duration: source.selectedTimeRange.duration)
        self.timeRange = source.selectedTimeRange
    }
    
    public func thumbnail(size: CGSize) async throws -> UIImage {
        guard let ciImage = source.resource.image(at: .zero, renderSize: size) else {
            throw Asset.Error.imageDecoding
        }
        return UIImage(ciImage: ciImage)
    }
    
    public enum CodingKeys: String, CodingKey {
        case url
        case timeRange
        case originalTime
        case type
    }
    
    public init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.url = try values.decode(URL.self, forKey: .url)
        self.type = .asset
        self.asset = AVURLAsset(url: url)
        self.source = AssetSource(urlAsset: asset)
        self.originalTime = try values.decode(CMTimeRange.self, forKey: .originalTime)
        self.timeRange = try values.decode(CMTimeRange.self, forKey: .timeRange)
    }
    
    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(url, forKey: .url)
        try container.encode(timeRange, forKey: .timeRange)
        try container.encode(originalTime, forKey: .originalTime)
        try container.encode(type, forKey: .type)
    }
}

extension Asset: Equatable {
    public static func == (lhs: Asset, rhs: Asset) -> Bool {
        if case .localFile(let lhsAsset) = lhs, case .localFile(let rhsAsset) = rhs {
            return lhsAsset.url == rhsAsset.url
        } else if case .photoLibrary(let lhsAsset) = lhs, case .photoLibrary(let rhsAsset) = rhs {
            return lhsAsset.localIdentifier == rhsAsset.localIdentifier
        } else if case .asset(let lhsAsset) = lhs, case .asset(let rhsAsset) = rhs {
            return lhsAsset.url == rhsAsset.url
        } else {
            return false
        }
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

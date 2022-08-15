//import VideoLab
//import AVKit
//
//public extension RenderLayer {
//    convenience init(asset: AVAsset) {
//        let source = AVAssetSource(asset: asset)
//        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
//        self.init(timeRange: source.selectedTimeRange, source: source)
//    }
//}
//
//public extension RenderComposition {
//    func addLayer(_ layer: RenderLayer) {
//        layers.append(layer)
//    }
//
//    func insertLayer(_ layer: RenderLayer, at index: Int) {
//        layers.insert(layer, at: index)
//    }
//
//    func addLayer(with asset: AVAsset) {
//        let source = AVAssetSource(asset: asset)
//        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
//        var timeRange = source.selectedTimeRange
//        if let lastLayer = layers.last {
//            timeRange.start = CMTimeRangeGetEnd(lastLayer.timeRange)
//            let renderLayer = RenderLayer(timeRange: timeRange, source: source)
//            layers.append(renderLayer)
//        } else {
//            let renderLayer = RenderLayer(timeRange: timeRange, source: source)
//            layers.append(renderLayer)
//        }
//    }
//    
//    func insertLayer(with asset: AVAsset, at index: Int) {
//        let source = AVAssetSource(asset: asset)
//        source.selectedTimeRange = CMTimeRange(start: CMTime.zero, duration: asset.duration)
//        var timeRange = source.selectedTimeRange
//        if index == 0 {
//            layers.insert(RenderLayer(timeRange: timeRange, source: source), at: index)
//            
//            let staringIdx = index+1
//            let endingIdx = layers.count
//            var previousLayer = layers[0]
//            
//            for i in staringIdx..<endingIdx {
//                let layer = layers[i]
//                timeRange = layer.timeRange
//                timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
//                layer.timeRange = timeRange
//                previousLayer = layer
//            }
//        } else {
//            var previousLayer = layers[index-1]
//            var timeRange = previousLayer.timeRange
//            timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
//            layers.insert(RenderLayer(timeRange: timeRange, source: source), at: index)
//            
//            let staringIdx = index
//            let endingIdx = layers.count
//            
//            for idx in staringIdx..<endingIdx {
//                let layer = layers[idx]
//                timeRange = layer.timeRange
//                previousLayer = layers[idx-1]
//                timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
//                layer.timeRange = timeRange
//            }
//        }
//    }
//    
//    @discardableResult
//    func removeLayer(at index: Int) -> RenderLayer? {
//        if layers.isEmpty { return nil }
//        let layer = layers.remove(at: index)
//        if layers.isEmpty { return layer }
//        
//        var previousLayer = layers[0]
//        var timeRange = previousLayer.timeRange
//        timeRange.start = CMTime.zero
//        previousLayer.timeRange = timeRange
//        
//        let staringIdx = 1
//        let endingIdx = layers.count
//        
//        for i in staringIdx..<endingIdx {
//            let layer = layers[i]
//            timeRange = layer.timeRange
//            timeRange.start = CMTimeRangeGetEnd(previousLayer.timeRange)
//            layer.timeRange = timeRange
//            previousLayer = layer
//        }
//        return layer
//    }
//}

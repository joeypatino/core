import AVFoundation

public extension CMTime {
    var humanReadable: String {
        let seconds = CMTimeGetSeconds(self)
        let secondText = String(format: "%02d", Int(seconds) % 60)
        let minuteText = String(format: "%02d", Int(seconds) / 60)
        return "\(minuteText):\(secondText)"
    }
}

public extension CMTime {
    static var frame: CMTime {
        CMTime(value: 1, timescale: 60)
    }
}

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
    static var oneFrame: CMTime {
        CMTime(seconds: 1, preferredTimescale: 30)
    }
}

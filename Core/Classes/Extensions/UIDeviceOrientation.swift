import UIKit
import AVFoundation

public extension UIDeviceOrientation {
    static var current: UIDeviceOrientation {
        return UIDevice.current.orientation
    }
    
    var avCaptureOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:                    return .portrait
        case .portraitUpsideDown:          return .portraitUpsideDown
        case .landscapeLeft:               return .landscapeRight
        case .landscapeRight:              return .landscapeLeft
        case .unknown, .faceUp, .faceDown: return nil
        @unknown default:
            return nil
        }
    }
}

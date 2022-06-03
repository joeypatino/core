import UIKit
import AVFoundation

public extension UIInterfaceOrientation {
    static var current: UIInterfaceOrientation {
        guard let orientation = UIApplication.shared.windows.first?.windowScene?.interfaceOrientation else {
            let errorMessage = "Could not obtain UIInterfaceOrientation from a valid windowScene"
#if DEBUG
            assertionFailure(errorMessage)
#else
            // TODO: Report Error with your error reporting tool.
#endif
            return .unknown
        }
        return orientation
    }
    
    var avCaptureOrientation: AVCaptureVideoOrientation? {
        switch self {
        case .portrait:           return .portrait
        case .portraitUpsideDown: return .portraitUpsideDown
        case .landscapeLeft:      return .landscapeLeft
        case .landscapeRight:     return .landscapeRight
        case .unknown:            return nil
        @unknown default:
            return nil
        }
    }
}

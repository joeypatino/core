import QuartzCore
import UIKit

public extension CALayer {
    func image() -> UIImage? {
        guard let context = CGContext(data: nil, width: frame.width.int, height: frame.height.int, bitsPerComponent: 8, bytesPerRow: frame.width.int * 8, space: CGColorSpaceCreateDeviceRGB(), bitmapInfo: CGImageAlphaInfo.premultipliedLast.rawValue) else { return nil }
        render(in: context)
        guard let cgImage = context.makeImage() else { return nil }
        return UIImage(cgImage: cgImage)
    }
}

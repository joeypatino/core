import Foundation

public extension String {
    func drawCentered(in rect: CGRect, attributes: [NSAttributedString.Key: Any]? = nil) {
        let string = self as NSString
        let sizeOfString = string.size(withAttributes: attributes)
        let boundsOrigin = CGPoint(x: rect.width / 2 - sizeOfString.width / 2,
                                   y: rect.height / 2 - sizeOfString.height / 2)
        let bounds = CGRect(origin: boundsOrigin, size: sizeOfString)
        string.draw(in: bounds, withAttributes: attributes)
    }
}

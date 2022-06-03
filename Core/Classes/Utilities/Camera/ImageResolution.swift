import Foundation

public enum ImageResolution: String {
    case three = "{1536, 2048}"
    case four = "{1632, 2464}"
    case six = "{2000, 3008}"
    case eight = "{2448, 3264}"
    case ten = "{2592, 3872}"
    case twelve = "{2800, 4290}"
    case sixteen = "{3264, 4920}"
    
    var portrait: CGSize {
        return NSCoder.cgSize(for: rawValue)
    }
    
    var landscape: CGSize {
        return CGSize(width: portrait.height, height: portrait.width)
    }
}

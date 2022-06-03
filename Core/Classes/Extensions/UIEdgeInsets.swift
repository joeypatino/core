import UIKit

public extension UIEdgeInsets {
    var horizontalLength: CGFloat {
        return left + right
    }

    var verticalLength: CGFloat {
        return top + bottom
    }
}

import CoreGraphics

public extension CGAffineTransform {
    var scaleX: CGFloat {
        sqrt(a * a + c * c)
    }

    var scaleY: CGFloat {
        sqrt(b * b + d * d)
    }
    
    var translationX: CGFloat {
        tx
    }
    var translationY: CGFloat {
        ty
    }
}

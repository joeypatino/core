import UIKit

public class RoundView: UIView {
    public override var bounds: CGRect {
        didSet { layer.cornerRadius = bounds.width / 2 }
    }
}

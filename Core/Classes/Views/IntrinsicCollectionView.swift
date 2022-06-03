import UIKit

public class IntrinsicCollectionView: UICollectionView {
    public override func layoutSubviews() {
        super.layoutSubviews()
        if !(bounds.size.equalTo(intrinsicContentSize)) {
            invalidateIntrinsicContentSize()
        }
    }
    
    public override var intrinsicContentSize: CGSize {
        return contentSize
    }
}

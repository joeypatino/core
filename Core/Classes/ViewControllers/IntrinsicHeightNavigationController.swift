import UIKit

open class IntrinsicHeightNavigationController: UINavigationController {
    private let usesSafeAreas: Bool
    public init(rootViewController: UIViewController, usesSafeAreas: Bool = false) {
        self.usesSafeAreas = usesSafeAreas
        super.init(rootViewController: rootViewController)
    }

    required public init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        NSLayoutConstraint.deactivate(view.constraintsAffectingLayout(for: .vertical).filter { $0.firstAnchor == view.heightAnchor })
        if let height = topViewController?.view.requiredHeight(fittingWidth: UIScreen.main.bounds.width) {
            view.heightAnchor.equalToConstant(height + (usesSafeAreas ? UIApplication.shared.windowSafeAreaInsets.verticalLength : UIApplication.shared.windowSafeAreaInsets.bottom))
        }
    }
}

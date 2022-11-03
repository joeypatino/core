import UIKit

public final class LoadingBannerModalPresentationController: ModalPresentationController {
    public var banner = UIView()
    private var bannerBackground = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    private var isLoading: Bool = false
    
    public init(banner: UIView, presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, canTapToDismiss: Bool = true, canSwipeDownToDismiss: Bool = true, shouldUseIntrinsicHeight: Bool = false, appliesPerspectiveTransform: Bool = true) {
        self.banner = banner
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController, canTapToDismiss: canTapToDismiss, canSwipeDownToDismiss: canSwipeDownToDismiss, shouldUseIntrinsicHeight: shouldUseIntrinsicHeight, appliesPerspectiveTransform: appliesPerspectiveTransform)
        self.bannerBackground.isUserInteractionEnabled = false
    }
    
    required public init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?, canTapToDismiss: Bool = true, canSwipeDownToDismiss: Bool = true, shouldUseIntrinsicHeight: Bool = false, appliesPerspectiveTransform: Bool = true) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController, canTapToDismiss: canTapToDismiss, canSwipeDownToDismiss: canSwipeDownToDismiss, shouldUseIntrinsicHeight: shouldUseIntrinsicHeight, appliesPerspectiveTransform: appliesPerspectiveTransform)
    }
    
    public override var frameOfPresentedViewInContainerView: CGRect {
        guard let containerBounds = containerView?.bounds else { return .zero }
        var frame = containerBounds
        frame.size.height = (containerBounds.height - topSpacing) - (isLoading ? heightForBanner: 0)
        frame.origin.y = containerBounds.height - frame.size.height
        return frame
    }
    
    public override func canDismiss() -> Bool {
        !isLoading
    }
    
    public func setIsLoading(_ isLoading: Bool) {
        let isShowingLoadingBanner = self.isLoading
        self.isLoading = isLoading
        switch isLoading {
        case true:
            isShowingLoadingBanner ? () : showActivityBanner()
        case false:
            isShowingLoadingBanner ? hideActivityBanner() : ()
        }
    }
}

extension LoadingBannerModalPresentationController {
    private var heightForBanner: CGFloat { banner.requiredHeight(fittingWidth: UIScreen.main.bounds.width) }
    
    private func showActivityBanner() {
        guard let containerBounds = containerView?.bounds, let presented = presentedView else { return }
        bannerBackground.alpha = 0
        bannerBackground.frame = containerBounds
        containerView!.insertSubview(bannerBackground, aboveSubview: presented)
        bannerBackground.layoutIfNeeded()
        
        banner.frame = CGRect(origin: containerBounds.origin, size: .init(width: containerBounds.width, height: heightForBanner))
        banner.transform = .init(translationX: 0, y: -heightForBanner)
        containerView!.insertSubview(banner, aboveSubview: bannerBackground)
        banner.layoutIfNeeded()

        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UISpringTimingParameters(dampingRatio: 1.0))
        animator.addAnimations {
            self.background.alpha = 0.7
            self.bannerBackground.alpha = 0.7
            self.banner.transform = .identity
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView.inset(by: .init(top: -self.topSpacing + 8, left: 0, bottom: 0, right: 0))
        }
        animator.startAnimation()
    }
    
    private func hideActivityBanner() {
        let animator = UIViewPropertyAnimator(duration: 0.5, timingParameters: UISpringTimingParameters(dampingRatio: 1.0))
        animator.addAnimations {
            self.background.alpha = 0.5
            self.banner.transform = .init(translationX: 0, y: -self.heightForBanner)
            self.banner.alpha = 0
            self.bannerBackground.alpha = 0
            self.presentedView?.frame = self.frameOfPresentedViewInContainerView
        }
        animator.addCompletion { _ in
            self.banner.removeFromSuperview()
            self.banner.alpha = 1
            self.bannerBackground.removeFromSuperview()
            self.bannerBackground.alpha = 0.7
            self.banner.transform = .identity
        }
        animator.startAnimation()
    }
}

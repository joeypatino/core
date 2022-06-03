import UIKit

public final class ActionSheetInteractiveTransition: UIPercentDrivenInteractiveTransition {
    private var presentingViewController: UIViewController?
    private let panGestureRecognizer: UIPanGestureRecognizer
    private var shouldComplete: Bool = false
    private var velocity: CGPoint = .zero
    
    public var isInteractive: Bool  { panGestureRecognizer.state != .possible }
    public init(presentingViewController: UIViewController?) {
        self.presentingViewController = presentingViewController
        self.panGestureRecognizer = UIPanGestureRecognizer()
        
        super.init()
    }
    
    public var enabled: Bool = false {
        didSet {
            guard enabled else {
                presentingViewController?.view.removeGestureRecognizer(panGestureRecognizer)
                return
            }
            panGestureRecognizer.addTarget(self, action: #selector(onPan))
            presentingViewController?.view.addGestureRecognizer(panGestureRecognizer)
        }
    }
    
    override public var completionSpeed: CGFloat {
        get { 1.0 - percentComplete }
        set {}
    }
    
    @objc func onPan(pan: UIPanGestureRecognizer) -> Void {
        let translation = pan.translation(in: pan.view?.superview)
        
        switch pan.state {
        case .began:
            presentingViewController?.dismiss(animated: true, completion: nil)
        case .changed:
            velocity = pan.velocity(in: nil)
            let screenHeight = pan.view?.frame.height ?? 0
            let dragAmount = screenHeight
            let threshold: Float = 0.3
            var percent = Float(translation.y) / Float(dragAmount)
            percent = fmaxf(percent, 0.0)
            percent = fminf(percent, 1.0)
            update(CGFloat(percent))
            
            shouldComplete = percent > threshold && velocity.y >= 0
        case .ended where shouldComplete:
            finish()
        case .cancelled where shouldComplete:
            finish()
        default:
            cancel()
        }
    }
}

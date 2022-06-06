import UIKit
import Core

class CAAnimationViewController: UIViewController {
    private let ring = RingView(duration: 5)
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        
    }
    
    private func layout() {
        view.addAutoLayoutSubview(ring)
        ring.centerYAnchor.equalTo(view.centerYAnchor)
        ring.centerXAnchor.equalTo(view.centerXAnchor)
        ring.widthAnchor.equalToConstant(100)
        
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("delete...", for: .normal)
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.heightAnchor.equalToConstant(60)
        button.centerXAnchor.equalTo(view.centerXAnchor)
        button.centerYAnchor.equalTo(view.centerYAnchor)
        button.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        ring.removeSegment()
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        ring.startAnimation()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        ring.stopAnimation()
    }
}

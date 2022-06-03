import UIKit
import Core

class CameraPlaygroundViewController: UIViewController {
    private let captureButton = CaptureButton()
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
        let button = UIButton()
        button.setTitleColor(.black, for: .normal)
        button.setTitle("Open...", for: .normal)
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.heightAnchor.equalToConstant(60)
        button.centerXAnchor.equalTo(view.centerXAnchor)
        button.centerYAnchor.equalTo(view.centerYAnchor)
        button.addTarget(self, action: #selector(showModalViewController(_:)), for: .touchUpInside)
        
        view.addAutoLayoutSubview(captureButton)
        captureButton.widthAnchor.equalToConstant(100)
        captureButton.topAnchor.equalTo(button.bottomAnchor).constant(160)
        captureButton.centerXAnchor.equalTo(view.centerXAnchor)
        captureButton.addTarget(self, action: #selector(onCaptureButtonSelected(_:)), for: .touchUpInside)
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        let viewController = CameraViewController()
        present(viewController, animated: true)
    }
    
    @objc private func onCaptureButtonSelected(_ sender: UIButton) {
        captureButton.start(duration: 10.0)
    }
}

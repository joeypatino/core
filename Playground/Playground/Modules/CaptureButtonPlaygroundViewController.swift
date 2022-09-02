import Foundation
import UIKit
import Core

class CaptureButtonPlaygroundViewController: UIViewController {
    private let button = VideoCaptureButton()
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(backgroundColor: .black)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }

    private func setup() {
        button.addTarget(self, action: #selector(onCaptureAction(_:)), for: .touchUpInside)
        button.addTarget(self, action: #selector(onCaptureStart(_:)), for: .editingDidBegin)
        button.addTarget(self, action: #selector(onCaptureEnd(_:)), for: .editingDidEnd)
        button.addTarget(self, action: #selector(onCaptureComplete(_:)), for: .editingDidEnd)
        button.strokeEnd = 0
    }
    
    private func layout() {
        view.addAutoLayoutSubview(button)
        button.widthAnchor.equalToConstant(100)
        button.centerYAnchor.equalTo(view.centerYAnchor)
        button.centerXAnchor.equalTo(view.centerXAnchor)
    }
    
    @objc private func onCaptureAction(_ sender: UIButton) {
        if button.isAnimating {
            button.stopAnimation()
        } else {
            do {
                try button.startAnimation()
            } catch {
                print("Error", error)
            }
        }
    }
    
    @objc private func onCaptureStart(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func onCaptureEnd(_ sender: UIButton) {
        print(#function)
    }
    
    @objc private func onCaptureComplete(_ sender: UIButton) {
        print(#function)
    }
}

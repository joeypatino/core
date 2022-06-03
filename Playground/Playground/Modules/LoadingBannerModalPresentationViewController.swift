import UIKit
import Core

class LoadingBannerModalPresentationViewController: UIViewController {
    private var loadingBanner: UIView = {
        let loadingBanner = UIView(backgroundColor: .white)
        loadingBanner.heightAnchor.equalToConstant(120)
        loadingBanner.setLayerCornerRadius(16, maskCorners: [.bottomLeftCorner, .bottomRightCorner])
        let activityIndicator = UIActivityIndicatorView(style: .medium)
        loadingBanner.addAutoLayoutSubview(activityIndicator)
        activityIndicator.centerXAnchor.equalTo(loadingBanner.centerXAnchor)
        activityIndicator.centerYAnchor.equalTo(loadingBanner.centerYAnchor)
        activityIndicator.startAnimating()
        return loadingBanner
    }()
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
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
        let viewController = ModalViewController()
        let presentationController = LoadingBannerModalPresentationController(banner: loadingBanner, presentedViewController: viewController, presenting: self)
        self.presentModal(presentationController)
        DispatchQueue.main.asyncAfter(delay: 0.75) {
            presentationController.setIsLoading(true)
        }
        
        DispatchQueue.main.asyncAfter(delay: 5) {
            presentationController.setIsLoading(false)
        }
    }
}

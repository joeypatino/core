import UIKit
import Photos

public protocol MediaCapturePresenter: ActionSheetViewControllerDelegate {
    var imagePicker: UIImagePickerController { get }
    var actionSheet: ActionSheetTransitioningDelegate? { get set }
    var defaultCamera: UIImagePickerController.CameraDevice { get }
    func presentMediaCaptureOptions()
}

extension MediaCapturePresenter where Self: UIViewController {
    public var defaultCamera: UIImagePickerController.CameraDevice { .front }
    
    public func presentMediaCaptureOptions() {
        actionSheet = ActionSheetTransitioningDelegate(presentingViewController: self)
        let viewController = ActionSheetViewController()
        let imageAction = ActionSheetAction(title: Localization.MediaCapture.openCamera.localizedString, icon: nil, action: {
            [weak self] in
            self?.showImagePicker(withType: .camera)
        })
        viewController.addAction(imageAction)

        let libraryAction = ActionSheetAction(title: Localization.MediaCapture.openLibrary.localizedString, icon: nil, action: {
            [weak self] in
            self?.showImagePicker(withType: .photoLibrary)
        })
        viewController.addAction(libraryAction)
        viewController.delegate = self
        viewController.transitioningDelegate = actionSheet
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }
    
    private func alertCameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let viewController = UIAlertController(title: Localization.MediaCapture.errorTitle.localizedString, message: Localization.MediaCapture.accessDisabled.localizedString, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: Localization.MediaCapture.settings.localizedString, style: .default) { _ in UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil) })
        viewController.addAction(UIAlertAction(title: Localization.MediaCapture.cancel.localizedString, style: .cancel))
        show(viewController, sender: nil)
    }
    
    private func showImagePicker(withType type: UIImagePickerController.SourceType) {
        defer {
            let status = PHPhotoLibrary.authorizationStatus()
            if status == .notDetermined  { PHPhotoLibrary.requestAuthorization({status in }) }
            present(imagePicker, animated: true)
        }
        imagePicker.sourceType = type
        guard type == .camera else { return }
        
        imagePicker.cameraDevice = UIImagePickerController.isCameraDeviceAvailable(defaultCamera) ? defaultCamera : defaultCamera.opposite
        imagePicker.cameraCaptureMode = .photo
    }
}

extension MediaCapturePresenter where Self: UIViewController {
    public func viewControllerDone(_ viewController: ActionSheetViewController, onCompletion completion: @escaping () -> Void) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
                completion()
            }
        } else {
            dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
                completion()
            }
        }
    }
    
    public func viewControllerDone(_ viewController: ActionSheetViewController) {
        viewControllerDone(viewController, onCompletion: {})
    }
    
    public func viewControllerDidCancel(_ viewController: ActionSheetViewController) {
        if let presented = presentedViewController {
            presented.dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
            }
        } else {
            dismiss(animated: true) { [weak self] in
                self?.actionSheet = nil
            }
        }
    }
}

extension UIImagePickerController.CameraDevice {
    fileprivate var opposite: UIImagePickerController.CameraDevice {
        switch self {
        case .front: return .rear
        case .rear: return .front
        @unknown default:
            return .rear
        }
    }
}

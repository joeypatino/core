import UIKit
import Photos

public protocol MediaCapturePresenter: ActionSheetViewControllerDelegate, AudioVideoPermissionPresenter {
    var imagePicker: UIImagePickerController { get }
    var actionSheet: ActionSheetTransitioningDelegate? { get set }
    var defaultCamera: UIImagePickerController.CameraDevice { get }
    func presentMediaCaptureOptions()
}

extension MediaCapturePresenter where Self: UIViewController {
    public var defaultCamera: UIImagePickerController.CameraDevice { .front }
    
    public func presentMediaCapture(_ actions: [ActionSheetAction] = []) {
        actionSheet = ActionSheetTransitioningDelegate(presentingViewController: self)
        let viewController = ActionSheetViewController()
        let imageAction = ActionSheetAction(title: Localization.MediaCapture.openCamera.localizedString, icon: nil, action: {
            [weak self] in
            self?.showImagePicker(withType: .camera)
        })
        let libraryAction = ActionSheetAction(title: Localization.MediaCapture.openLibrary.localizedString, icon: nil, action: {
            [weak self] in
            self?.showImagePicker(withType: .photoLibrary)
        })
        viewController.addAction(imageAction)
        viewController.addAction(libraryAction)
        actions.forEach { viewController.addAction($0) }
        viewController.delegate = self
        viewController.transitioningDelegate = actionSheet
        viewController.modalPresentationStyle = .custom
        present(viewController, animated: true)
    }
    
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
    
    public func presentCamera() {
        Task {
            if await checkPermission(mode: .camera) {
                DispatchQueue.main.async {
                    self.showImagePicker(withType: .camera)
                }
            }
        }
    }
    
    public func presentPhotosLibrary() {
        Task {
            if await checkPermission(mode: .camera) {
                DispatchQueue.main.async {
                    self.showImagePicker(withType: .photoLibrary)
                }
            }
        }
    }
        
    private func alertCameraAccessNeeded() {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let viewController = UIAlertController(title: Localization.MediaCapture.errorTitle.localizedString, message: Localization.MediaCapture.accessDisabled.localizedString, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: Localization.MediaCapture.settings.localizedString, style: .default) { _ in UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil) })
        viewController.addAction(UIAlertAction(title: Localization.MediaCapture.cancel.localizedString, style: .cancel))
        show(viewController, sender: nil)
    }
    
    private func showImagePicker(withType type: UIImagePickerController.SourceType) {
        if UIDevice.isSimulator && type == .camera {
            imagePicker.delegate?.imagePickerController?(imagePicker, didFinishPickingMediaWithInfo: [.originalImage: simulatorPhoto()])
            return
        }
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

extension MediaCapturePresenter {
    private func simulatorPhoto() -> UIImage {
        defer { UIGraphicsEndImageContext() }
        
        let backgroundColor = UIColor.random
        let resolution = ImageResolution.sixteen
        let description = "The camera is not\navailable in the simulator\n" + Date().localizedString()
        let size = UIDevice.current.orientation.isPortrait
        ? resolution.portrait
        : resolution.landscape
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(size, true, 1)
        backgroundColor.setFill()
        UIRectFill(rect)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.alignment = .center
        let attributes: [NSAttributedString.Key: Any]?
        attributes = [.font: UIFont.systemFont(ofSize: 160, weight: .medium),
                      .foregroundColor: UIColor.white,
                      .paragraphStyle: paragraphStyle]
        
        let image = UIGraphicsGetImageFromCurrentImageContext()
        return image!.overlay(string: description, withAttributes: attributes)!
    }
}

fileprivate extension UIImage {
    func overlay(string: String?, withAttributes attributes: [NSAttributedString.Key: Any]? = nil) -> UIImage? {
        guard let string = string else { return self }
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        let rect = CGRect(origin: .zero, size: size)
        
        draw(in: rect)
        string.drawCentered(in: rect, attributes: attributes)
        return UIGraphicsGetImageFromCurrentImageContext()
    }
}


fileprivate extension Date {
    func localizedString(dateStyle: DateFormatter.Style = .medium, timeStyle: DateFormatter.Style = .medium) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = dateStyle
        formatter.timeStyle = timeStyle
        
        return formatter.string(from: self)
    }
}

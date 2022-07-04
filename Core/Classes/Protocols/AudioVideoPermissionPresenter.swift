import UIKit
import AVKit
import Contacts

public enum Permission {
    case camera
    case microphone
    case contacts
    case notifications
}

public protocol AudioVideoPermissionPresenter {
    func checkPermission(mode: Permission) async -> Bool
    
    var titleForCameraAccessAlert: String { get }
    var titleForMicrophoneAccessAlert: String { get }
    var titleForContactsAccessAlert: String { get }
    var titleForNotificationsAccessAlert: String { get }
    
    var titleForAlert: String { get }
    var titleForSettingsButton: String { get }
    var titleForCancelButton: String { get }
}

public extension AudioVideoPermissionPresenter where Self: UIViewController {
    func checkPermission(mode: Permission) async -> Bool {
        switch mode {
        case .camera:
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
            switch cameraAuthorizationStatus {
            case .restricted, .denied:
                alertCameraAccessNeeded()
                return false
            default:
                return true
            }
        case .microphone:
            let micAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .audio)
            switch micAuthorizationStatus {
            case .restricted, .denied:
                alertMicrophoneAccessNeeded()
                return false
            default:
                return true
            }
        case .contacts:
            let contactsAuthorizationStatus = CNContactStore.authorizationStatus(for: .contacts)
            switch contactsAuthorizationStatus {
            case .restricted, .denied:
                alertContactsAccessNeeded()
                return false
            default:
                return true
            }
        default:
            break
        }
        
        return await withCheckedContinuation { continuation in
            switch mode {
            case .notifications:
                UNUserNotificationCenter.current().getNotificationSettings { settings in
                    switch settings.authorizationStatus {
                    case .denied:
                        DispatchQueue.main.async {
                            self.alertNotificationsAccessNeeded()
                            continuation.resume(with: .success(false))
                        }
                    default:
                        continuation.resume(with: .success(true))
                    }
                }
            default:
                break
            }
        }
    }
    
    var titleForCameraAccessAlert: String { "Camera access has been disabled. Tap To View Settings" }
    var titleForMicrophoneAccessAlert: String { "Microphone access has been disabled. Tap To View Settings" }
    var titleForContactsAccessAlert: String { "Contacts access has been disabled. Tap To View Settings" }
    var titleForNotificationsAccessAlert: String { "Notifications access has been disabled. Tap To View Settings" }
    
    var titleForAlert: String { "Access Requested" }
    var titleForSettingsButton: String { "Settings" }
    var titleForCancelButton: String { "Cancel" }
}

extension AudioVideoPermissionPresenter where Self: UIViewController {
    private func alertCameraAccessNeeded() {
        presentAlert(titleForCameraAccessAlert)
    }
    
    private func alertMicrophoneAccessNeeded() {
        presentAlert(titleForMicrophoneAccessAlert)
    }
    
    private func alertContactsAccessNeeded() {
        presentAlert(titleForContactsAccessAlert)
    }
    
    private func alertNotificationsAccessNeeded() {
        presentAlert(titleForNotificationsAccessAlert)
    }
    
    private func presentAlert(_ message: String) {
        guard let settingsAppURL = URL(string: UIApplication.openSettingsURLString) else { return }
        let viewController = UIAlertController(title: titleForAlert, message: message, preferredStyle: .alert)
        viewController.addAction(UIAlertAction(title: titleForSettingsButton, style: .default) { _ in UIApplication.shared.open(settingsAppURL, options: [:], completionHandler: nil) })
        viewController.addAction(UIAlertAction(title: titleForCancelButton, style: .cancel))
        present(viewController, animated: true)
    }
}

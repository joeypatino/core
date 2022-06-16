import Foundation

public struct Localization {
    private init() {}
    
    enum MediaCapture: String, Localizable {
        case openCamera = "media_capture_capture_photo"
        case openLibrary = "media_capture_select_from_library"
        case errorTitle = "media_capture_error_title"
        case accessDisabled = "media_capture_access_disabled"
        case settings = "media_capture_settings_button"
        case cancel = "media_capture_cancel_button"
        
        var bundle: Bundle {
            return Bundle(identifier: "com.joeypatino.core")!
        }
    }
    
    enum ActionSheet: String, Localizable {
        case cancel = "action_sheet_cancel_button"
        
        var bundle: Bundle {
            return Bundle(identifier: "com.joeypatino.core")!
        }
    }

    enum Validators: String, Localizable {
        case emailHint = "email_validation_hint"
        case nameHint = "name_validation_hint"
        case notEmptyHint = "notEmpty_validation_hint"
        
        var bundle: Bundle {
            return Bundle(identifier: "com.joeypatino.core")!
        }
    }

}

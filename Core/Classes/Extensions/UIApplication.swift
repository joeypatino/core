import UIKit

public extension UIApplication {
    var windowSafeAreaInsets: UIEdgeInsets {
        sharedSceneWindow?.safeAreaInsets ?? .zero
    }
}

public extension UIApplication {
    var sharedSceneWindow: UIWindow? {
        UIApplication
        .shared
        .connectedScenes
        .flatMap { ($0 as? UIWindowScene)?.windows ?? [] }
        .first { $0.isKeyWindow }
    }
}

public extension UIApplication {
    var sharedScene: UIWindowScene? {
        UIApplication
        .shared
        .connectedScenes
        .compactMap { ($0 as? UIWindowScene) }
        .first
    }
}

public extension UIApplication {
    /// Application running environment.
    /// - debug: Application is running in debug mode.
    /// - testFlight: Application is installed from Test Flight.
    /// - appStore: Application is installed from the App Store.
    enum Environment {
        /// Application is running in debug mode.
        case debug
        /// Application is installed from Test Flight.
        case testFlight
        /// Application is installed from the App Store.
        case appStore
    }

    /// Current inferred app environment.
    var inferredEnvironment: Environment {
        #if DEBUG
        return .debug

        #elseif targetEnvironment(simulator)
        return .debug

        #else
        if Bundle.main.path(forResource: "embedded", ofType: "mobileprovision") != nil {
            return .testFlight
        }

        guard let appStoreReceiptUrl = Bundle.main.appStoreReceiptURL else {
            return .debug
        }

        if appStoreReceiptUrl.lastPathComponent.lowercased() == "sandboxreceipt" {
            return .testFlight
        }

        if appStoreReceiptUrl.path.lowercased().contains("simulator") {
            return .debug
        }

        return .appStore
        #endif
    }

    /// Application name (if applicable).
    var displayName: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String
    }

    /// App current build number (if applicable).
    var buildNumber: String? {
        return Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as? String
    }

    /// App's current version number (if applicable).
    var version: String? {
        return Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String
    }
}

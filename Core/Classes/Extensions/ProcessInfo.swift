import Foundation

public extension ProcessInfo {
    static var isRunningUITest: Bool {
        processInfo.environment["isUIUnitTest"] == "YES"
    }
}

import Foundation
import Dispatch

public extension DispatchQueue {
    static var background: DispatchQueue {
        return DispatchQueue.global(qos: .background)
    }

    static var userInitiated: DispatchQueue {
        return DispatchQueue.global(qos: .userInitiated)
    }

    static var userInteractive: DispatchQueue {
        return DispatchQueue.global(qos: .userInteractive)
    }

    func asyncAfter(delay: TimeInterval, execute work: @escaping @convention(block) () -> Void) {
        self.asyncAfter(deadline: .now() + delay) {
            work()
        }
    }
    
    func debounce(delay: TimeInterval, action: @escaping @convention(block) () -> Void) -> () -> Void {
            // http://stackoverflow.com/questions/27116684/how-can-i-debounce-a-method-call
            var lastFireTime = DispatchTime.now()
            let deadline = { lastFireTime + delay }
            return {
                self.asyncAfter(deadline: deadline()) {
                    let now = DispatchTime.now()
                    if now >= deadline() {
                        lastFireTime = now
                        action()
                    }
                }
            }
        }
}

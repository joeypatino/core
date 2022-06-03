import Foundation

public extension NotificationCenter {
    /// Adds a one-time entry to the notification center to receive notifications that passed to the provided block.
    /// - Parameters:
    ///   - name: The name of the notification to register for delivery to the observer block. Specify a notification name to deliver only entries with this notification name. When nil, the sender doesn’t use notification names as criteria for delivery.
    ///   - obj: The object that sends notifications to the observer block. Specify a sender to deliver only notifications from this sender. When nil, the notification center doesn’t use the sender as criteria for the delivery.
    ///   - queue: The operation queue where the block runs. When nil, the block runs synchronously on the posting thread.
    ///   - block: The block that executes when receiving a notification. The notification center copies the block. The notification center strongly holds the copied block until you remove the observer registration. The block takes one argument: the notification.
    func observeOnce(forName name: NSNotification.Name?,
                     object obj: Any? = nil,
                     queue: OperationQueue? = nil,
                     using block: @escaping (_ notification: Notification) -> Void) {
        var handler: NSObjectProtocol!
        handler = addObserver(forName: name, object: obj, queue: queue) { [unowned self] in
            self.removeObserver(handler!)
            block($0)
        }
    }
}

import UIKit

public extension UITableView {
    func scrollToBottom(animated: Bool = false) {
        let tableViewContentHeight = contentSize.height
        performBatchUpdates(nil) { _ in
            self.scrollRectToVisible(CGRect(x: 0.0, y: tableViewContentHeight - 1.0, width: 1.0, height: 1.0), animated: animated)
        }
    }
}

public extension UITableView {
    func reloadDataAndKeepOffset() {
        // stop scrolling
        setContentOffset(contentOffset, animated: false)
        
        // calculate the offset and reloadData
        let beforeContentSize = contentSize
        reloadData()
        layoutIfNeeded()
        let afterContentSize = contentSize
        
        // reset the contentOffset after data is updated
        let newOffset = CGPoint(
            x: contentOffset.x + (afterContentSize.width - beforeContentSize.width),
            y: contentOffset.y + (afterContentSize.height - beforeContentSize.height))
        setContentOffset(newOffset, animated: false)
    }
}

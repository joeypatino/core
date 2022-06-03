import UIKit

@objc public protocol PaginatedTableViewDataSource: AnyObject {
    @objc func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    @objc func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    @objc func numberOfSections(in tableView: UITableView) -> Int
    @objc optional func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle
    @objc optional func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath)
    
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

@objc public protocol PaginatedTableViewDelegate: AnyObject {
    func reload(_ pageSize: Int, onSuccess: ((Bool) -> Void)?, onError: ((Error) -> Void)?)
    func load(_ pageNumber: Int, _ pageSize: Int, onSuccess: ((Bool) -> Void)?, onError: ((Error) -> Void)?)
    
    @objc optional func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath)
    @objc func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat
    @objc optional func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat
    @objc optional func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath)
    @objc optional func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat
    @objc optional func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView?
    @objc optional func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    @objc optional func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration?
    
    @objc optional func scrollViewDidScroll(_ scrollView: UIScrollView)
    @objc optional func scrollViewWillBeginDragging(_ scrollView: UIScrollView)
    @objc optional func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool)
}

/// A wrapper around table view to make pagination easier and reuseable.
open class PaginatedTableView: UITableView {
    // Only assign this delegate, not tableDelegate
    weak open var paginatedDelegate: PaginatedTableViewDelegate?
    // Only assign this dataSource, not tableDataSource
    weak open var paginatedDataSource: PaginatedTableViewDataSource?

    public var pageSize = 10
    public private(set) var currentPage = 1
    public private(set) var isLoading = false

    // First page can vary for different APIs thus can be changed from the VC
    private var indexForFirstPage = 0
    private var hasMoreData = true
    
    // Table view settings
    private var sections = 0
    private var loadMoreViewHeight: CGFloat = 100
    private var heightForHeaderInSection: CGFloat = 0
    private var titleForHeaderInSection = ""
    private var pullToRefreshTitle: NSAttributedString? = nil {
        didSet { refreshControltableView.attributedTitle = pullToRefreshTitle }
    }
    private var enablePullToRefresh = false {
        willSet {
            if newValue == enablePullToRefresh { return }
            if newValue {
                addSubview(refreshControltableView)
            } else {
                refreshControltableView.removeFromSuperview()
            }
        }
    }

    private lazy var refreshControltableView: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.attributedTitle = pullToRefreshTitle
        refreshControl.addTarget(self, action: #selector(self.handleRefreshtableView(_:)), for: UIControl.Event.valueChanged)
        return refreshControl
    }()
    
    // MARK: Initializers
    
    override init(frame: CGRect, style: UITableView.Style) {
        super.init(frame: frame, style: style)
        setup()
    }
    
    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        delegate = self
        dataSource = self
        prefetchDataSource = self
        alwaysBounceVertical = true
        
        // Enable pull to refresh control
        enablePullToRefresh = true
        
        // register load more cell
        register(PaginatedTableViewLoadMoreCell.self, forCellReuseIdentifier: String(describing: PaginatedTableViewLoadMoreCell.self))
    }

    // MARK: Private
    
    public func reloadData(reset: Bool = false) {
        reload(reset: reset)
    }
    
    // All loading logic goes here i.e. showing/hiding of loaders and pagination
    private func reload(reset: Bool = false) {
        if isLoading { return }

        // reset page number if refresh
        if reset {
            currentPage = indexForFirstPage
            hasMoreData = true
        }
        
        // return if already loading or dont have any more data
        if !hasMoreData { return }
        
        // start loading
        isLoading = true
        let onSuccess: ((Bool) -> Void) = { hasMore in
            self.hasMoreData = hasMore
            self.currentPage += 1
            self.isLoading = false
            self.refreshControltableView.endRefreshing()
            self.reloadData()
        }
        let onError: ((Error) -> Void)? = { _ in
            self.refreshControltableView.endRefreshing()
            self.isLoading = false
            self.hasMoreData = false
            if self.sections == 1 {
                self.reloadSections(IndexSet([0]), with: .automatic)
            }
        }
        if currentPage == indexForFirstPage {
            paginatedDelegate?.reload(pageSize, onSuccess: onSuccess, onError: onError)
        } else {
            paginatedDelegate?.load(currentPage, pageSize, onSuccess: onSuccess, onError: onError)
        }
    }

    // MARK: Actions
    
    @objc fileprivate func handleRefreshtableView(_ refreshControl: UIRefreshControl) {
        reload(reset: true)
    }
}

extension PaginatedTableView {
    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let height = scrollView.frame.size.height
        let contentYoffset = scrollView.contentOffset.y
        let distanceFromBottom = scrollView.contentSize.height - contentYoffset
        if distanceFromBottom < height {
            reload()
        }
        
        paginatedDelegate?.scrollViewDidScroll?(scrollView)
    }
    
    public func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        paginatedDelegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    public func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        paginatedDelegate?.scrollViewDidEndDragging?(scrollView, willDecelerate: decelerate)
    }
}

extension PaginatedTableView: UITableViewDataSource, UITableViewDelegate {
    public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // Return item for loader in case of last section
        if section == sections - 1 {
            // always have 1 row for the loader section - hide it using a zero height in `heightForRowAt:`
            return 1
        } else {
            return paginatedDataSource?.tableView(tableView, numberOfRowsInSection: section) ?? 0
        }
    }
    
    public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // If it is loading section
        if indexPath.section == sections - 1 {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PaginatedTableViewLoadMoreCell.self), for: indexPath) as? PaginatedTableViewLoadMoreCell else {
                fatalError("The dequeued cell is not an instance of LoadMoreCell.")
            }
            isLoading ? cell.startAnimating() : cell.stopAnimating()
            cell.separatorInset = .init(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            return cell
        } else {
            // return whatever cells user wants to
            return paginatedDataSource?.tableView(tableView, cellForRowAt: indexPath) ?? UITableViewCell()
        }
    }
    
    public func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return paginatedDelegate?.tableView?(tableView, estimatedHeightForRowAt: indexPath) ?? estimatedRowHeight
    }
    
    public func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paginatedDelegate?.tableView?(tableView, willDisplay: cell, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        paginatedDelegate?.tableView?(tableView, didEndDisplaying: cell, forRowAt: indexPath)
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        // Add one section for loader
        sections = 1
        
        // Add sections to one for loader
        if let numberOfSections = paginatedDataSource?.numberOfSections(in: tableView) {
            sections += numberOfSections
        }
        return sections
    }
    
    public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        return paginatedDelegate?.tableView?(tableView, viewForHeaderInSection: section)
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        paginatedDelegate?.tableView?(tableView, didSelectRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return titleForHeaderInSection
    }
    
    public func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return paginatedDelegate?.tableView?(tableView, heightForHeaderInSection: section) ?? heightForHeaderInSection
    }
    
    public func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.section == sections - 1 {
            // the section that has the loading indicator
            let isRefreshing = refreshControl?.isRefreshing ?? false
            if !isRefreshing && isLoading {
                return loadMoreViewHeight
            }
            return 0.0
        }
        return paginatedDelegate?.tableView(tableView, heightForRowAt: indexPath) ?? 0
    }
    
    public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        paginatedDataSource?.tableView?(tableView, commit: editingStyle, forRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return paginatedDataSource?.tableView?(tableView, editingStyleForRowAt: indexPath) ?? .none
    }
    
    public func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return paginatedDelegate?.tableView?(tableView, leadingSwipeActionsConfigurationForRowAt: indexPath)
    }
    
    public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return paginatedDelegate?.tableView?(tableView, trailingSwipeActionsConfigurationForRowAt: indexPath)
    }
}

// MARK: Prefetching data source
extension PaginatedTableView: UITableViewDataSourcePrefetching {
    public func tableView(_ tableView: UITableView, prefetchRowsAt indexPaths: [IndexPath]) {
        if indexPaths.contains(where: { $0.section == sections - 1 }) {
            reload()
        }
    }
}

private class PaginatedTableViewLoadMoreCell : UITableViewCell {
    private let activityIndicator : UIActivityIndicatorView = {
        let activityIndicator = UIActivityIndicatorView()
        activityIndicator.hidesWhenStopped = true
        activityIndicator.color = .gray
        return activityIndicator
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func startAnimating() {
        activityIndicator.startAnimating()
    }
    
    public func stopAnimating() {
        activityIndicator.startAnimating()
    }
}

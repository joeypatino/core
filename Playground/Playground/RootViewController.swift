import UIKit
import Core

enum Playgrounds: String, CaseIterable {
    case modalPresentation
    case modalPresentationWithLoadingBanner
    case pageIndicatorView
    case actionSheet
    case mediaCaptureOptions
    case cameraCapture
    case mediaPlayer
    case videoEditor
}

class RootViewController: UIViewController {
    private let table = UITableView()
    override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        table.register(PlaygroundCell.self, forCellReuseIdentifier: String(describing: PlaygroundCell.self))
        table.tableFooterView = UIView()
        table.delegate = self
        table.dataSource = self
        table.reloadData()
    }
    
    private func layout() {
        table.embed(in: view)
    }
}

extension RootViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let playground = Playgrounds.allCases[indexPath.row]
        switch playground {
        case .modalPresentation:
            show(ModalPresentationViewController(), sender: nil)
        case .modalPresentationWithLoadingBanner:
            show(LoadingBannerModalPresentationViewController(), sender: nil)
        case .pageIndicatorView:
            show(PageIndicatorViewController(), sender: nil)
        case .actionSheet:
            show(ActionSheetPlaygroundViewController(), sender: nil)
        case .mediaCaptureOptions:
            show(MediaCapturePlaygroundViewController(), sender: nil)
        case .cameraCapture:
            show(CameraPlaygroundViewController(), sender: nil)
        case .mediaPlayer:
            show(VideoPlayerPlaygroundViewController(), sender: nil)
        case .videoEditor:
            show(VideoEditorPlaygroundViewController(), sender: nil)
        }
    }
}

extension RootViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        Playgrounds.allCases.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: String(describing: PlaygroundCell.self), for: indexPath) as! PlaygroundCell
        cell.title = Playgrounds.allCases[indexPath.row].rawValue.capitalized
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        1
    }
}

class PlaygroundCell: UITableViewCell {
    private var label = UILabel(font: .systemFont(ofSize: 16, weight: .heavy), color: .black)
    var title: String = "" {
        didSet { label.text = title }
    }
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setup()
        layout()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setup() {
        
    }
    
    private func layout() {
        label.embed(in: contentView, inset: .init(top: 16, left: 32, bottom: 16, right: 32))
    }
}

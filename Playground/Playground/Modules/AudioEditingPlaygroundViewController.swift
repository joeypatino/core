import UIKit
import Core

class AudioEditingPlaygroundViewController: UIViewController {
    private let waveform = WaveformView()
    
    public init() {
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        view = UIView(backgroundColor: .white)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        layout()
    }
    
    private func setup() {
        let url = Bundle.main.url(forResource: "audio_sample_2", withExtension: "aiff")
        waveform.audioURL = url
    }
    
    private func layout() {
        view.addAutoLayoutSubview(waveform)
        waveform.leadingAnchor.equalTo(view.leadingAnchor).constant(16)
        waveform.trailingAnchor.equalTo(view.trailingAnchor).constant(-16)
        waveform.centerYAnchor.equalTo(view.centerYAnchor)
        waveform.heightAnchor.equalToConstant(80)
    }
    
    @objc private func showModalViewController(_ sender: UIButton) {
    }
}

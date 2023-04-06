import UIKit
import AVFoundation

public protocol CameraDelegate: AnyObject {
    func camera(_ session: Camera, captureModeDidChange captureMode: Camera.CaptureMode)
    func cameraVideoCaptureDidBegin(_ session: Camera)
    func cameraVideoCaptureDidFinish(_ session: Camera, withVideoURL url: URL)
    func camera(_ session: Camera, didCapturePhoto photo: UIImage, photoURL url: URL)
    func cameraPhotoCaptureDidFail(_ session: Camera, withError error: Camera.Error)
}

public final class Camera: NSObject {
    public enum Error: Swift.Error {
        case photoCaptureFailed
        case invalidState
    }
    public enum CaptureMode {
        case photo
        case video(isRecording: Bool)
    }
    public enum CameraPosition {
        case front
        case back
    }

    /// the session delegate
    public weak var delegate: CameraDelegate?

    /// the preview
    public weak var preview: CameraPreview? {
        didSet {
            preview?.session = session
            didUpdateCaptureMode(mode)
        }
    }

    /// the internal capture session object
    public let session = AVCaptureSession()
    
    /// the current capture mode. video or photo
    public private(set) var mode: CaptureMode {
        didSet { delegate?.camera(self, captureModeDidChange: mode) }
    }
    
    /// the current camera position. This will silently fail if the device does not support the selected configuration
    public var position: CameraPosition = .back {
        didSet { setupCaptureSession() }
    }
    
    // return true if there currently a video recording taking place
    public var isRecording: Bool {
        if case .video(let isRecording) = mode, isRecording == true {
            return true
        }
        return false
    }
    
    /// The maximum duration of a recorded video clip (in seconds). Set to Int64.max for no limit
    public var maxVideoDuration: Int64 = Int64.max {
        didSet { maxRecordedDuration = maxVideoDuration == Int64.max ? CMTime.invalid : CMTime(value: maxVideoDuration, timescale: 1) }
    }
    public var captureSessionPresent: AVCaptureSession.Preset = .hd1280x720
    
    private var videoFileOutput: AVCaptureMovieFileOutput?
    private var photoCaptureOutput: AVCapturePhotoOutput?
    private var maxRecordedDuration: CMTime = CMTime.invalid {
        didSet { didUpdateCaptureMode(mode) }
    }
    
    public init(captureMode: CaptureMode = .photo) {
        self.mode = captureMode
        super.init()
        setupCaptureSession()
        didUpdateCaptureMode(captureMode)   // needed to setup correct state!
    }
    
    public func capture() {
        switch mode {
        case .photo:
            captureImage()
        case .video(let isRecording):
            isRecording ? stopRecording() : startRecording()
            if !isRecording { mode = .video(isRecording: !isRecording) }
        }
    }
    
    public func startRunning() {
        DispatchQueue.background.async { self.session.startRunning() }
    }
    
    public func stopRunning() {
        DispatchQueue.background.async { self.session.stopRunning() }
    }

    /// starts recording a video. fails if the capture mode is not video
    private func startRecording() {
        guard case .video(let recording) = mode, recording == false else {
            assertionFailure("invalid capture mode")
            return
        }
        
        videoFileOutput?.startRecording(to: FileManager.default.temporaryMovieURL, recordingDelegate: self)
        delegate?.cameraVideoCaptureDidBegin(self)
    }
    
    /// stops recording the video and calls the completion after the video has been written to disk.
    private func stopRecording() {
        guard isRecording else { return }
        videoFileOutput?.stopRecording()
    }
    
    /// captures an image of the current capture session
    private func captureImage() {
        guard case .photo = mode else {
            assertionFailure("invalid capture mode")
            return
        }
        if UIDevice.isSimulator {
            let description = "The camera is not\navailable in the simulator\n"
            let date = Date()
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .medium
            
            let resolution = ImageResolution.eight
            let size = UIDevice.current.orientation.isPortrait ? resolution.portrait : resolution.landscape
            let color = UIColor.random
            
            let paragraph = NSMutableParagraphStyle()
            paragraph.alignment = .center
            let attrs = [.font: UIFont.systemFont(ofSize: 160, weight: .medium),
                         .foregroundColor: UIColor.white,
                         .paragraphStyle: paragraph] as [NSAttributedString.Key: Any]
            
            let i = UIImage(color: color, size: size)
            let image = i.overlaying(string: description + formatter.string(from: date), withAttributes: attrs)
            guard
                let data = image.jpegData(compressionQuality: 1.0) else {
                delegate?.cameraPhotoCaptureDidFail(self, withError: Camera.Error.photoCaptureFailed)
                return
            }
            do {
                let location = FileManager.default.temporaryPhotoURL
                try data.write(to: location)
                delegate?.camera(self, didCapturePhoto: image, photoURL: location)
            } catch {
                delegate?.cameraPhotoCaptureDidFail(self, withError: Camera.Error.photoCaptureFailed)
            }
        } else {
            photoCaptureOutput?.capturePhoto(with: AVCapturePhotoSettings(format: [AVVideoCodecKey: AVVideoCodecType.jpeg]), delegate: self)
        }
    }
        
    // MARK: tasks
    private func didUpdateCaptureMode(_ mode: CaptureMode) {
        guard let captureConnection = preview?.connection else { return }
        switch mode {
        case .photo:
            photoCaptureOutput = getPhotoCaptureOutput()
            photoCaptureOutput?.connection(with: .video)?.videoOrientation = captureConnection.videoOrientation
        case .video:
            videoFileOutput = getVideoCaptureOutput()
            videoFileOutput?.connection(with: .video)?.videoOrientation = captureConnection.videoOrientation
        }
    }
    
    private func setupCaptureSession() {
        guard
            let captureDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: position == .front ? .front : .back),
            let deviceInput = try? AVCaptureDeviceInput(device: captureDevice)
        else { return }
        
        session.beginConfiguration()
        defer { session.commitConfiguration(); preview?.session = session }
        
        session.inputs.forEach { session.removeInput($0) }
        if session.canAddInput(deviceInput) {
            session.addInput(deviceInput)
        }
        
        guard
            let microphone = AVCaptureDevice.default(for: .audio),
            let audioInput = try? AVCaptureDeviceInput(device: microphone)
        else { return }
        
        if session.canAddInput(audioInput) {
            session.addInput(audioInput)
        }
    }
    
    private func getPhotoCaptureOutput() -> AVCapturePhotoOutput {
        removeAllOutputs()
        return session.setCaptureOutput(AVCapturePhotoOutput(), withPreset: captureSessionPresent) as AVCapturePhotoOutput
    }
    
    private func getVideoCaptureOutput() -> AVCaptureMovieFileOutput {
        removeAllOutputs()
        let output = AVCaptureMovieFileOutput()
        output.maxRecordedDuration = maxRecordedDuration
        return session.setCaptureOutput(output, withPreset: captureSessionPresent)
    }
        
    private func removeAllOutputs() {
        session.outputs.filter { $0 is AVCaptureMovieFileOutput }.forEach { session.removeOutput($0) }
        session.outputs.filter { $0 is AVCapturePhotoOutput }.forEach { session.removeOutput($0) }
        
        videoFileOutput = nil
        photoCaptureOutput = nil
    }
}

extension Camera: AVCapturePhotoCaptureDelegate {
    public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Swift.Error?) {
        guard
            let captureConnection = preview?.connection,
            let image = photo.image(inOrientation: captureConnection.videoOrientation),
            let data = image.jpegData(compressionQuality: 1.0) else {
            delegate?.cameraPhotoCaptureDidFail(self, withError: Camera.Error.photoCaptureFailed)
            return
        }
        do {
            let location = FileManager.default.temporaryPhotoURL
            try data.write(to: location)
            delegate?.camera(self, didCapturePhoto: image, photoURL: location)
        } catch {
            delegate?.cameraPhotoCaptureDidFail(self, withError: Camera.Error.photoCaptureFailed)
        }
    }
}

extension Camera: AVCaptureFileOutputRecordingDelegate {
    public func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Swift.Error?) {
        delegate?.cameraVideoCaptureDidFinish(self, withVideoURL: outputFileURL)
        mode = .video(isRecording: false)
    }
}

private extension AVCaptureSession {
    func setCaptureOutput<T>(_ output: T, withPreset preset: Preset) -> T where T: AVCaptureOutput {
        if let oldOutput = outputs.first(where: { $0 is T }) as? T {
            return oldOutput
        }
        if canAddOutput(output) {
            addOutput(output)
        }
        sessionPreset = preset
        return output
    }
}

private extension AVCapturePhoto {
    var orientationMap: [AVCaptureVideoOrientation: CGImagePropertyOrientation] {
        return [
            .portrait: .right,
            .portraitUpsideDown: .left,
            .landscapeLeft: .down,
            .landscapeRight: .up]
    }
    
    func image(inOrientation orientation: AVCaptureVideoOrientation) -> UIImage? {
        guard let imageOrientation = orientationMap[orientation] else { return nil }
        
        let orientation = Int32(imageOrientation.rawValue)
        let context = CIContext()
        
        guard let imageData = fileDataRepresentation(),
              let ciimage = CIImage(data: imageData)?.oriented(forExifOrientation: orientation),
              let cgimage = context.createCGImage(ciimage, from: ciimage.extent) else {
            return nil
        }
        return UIImage(cgImage: cgimage)
    }
}

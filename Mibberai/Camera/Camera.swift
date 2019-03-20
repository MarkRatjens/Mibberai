import AVFoundation

public protocol CameraDelegate: class {
	func cameraOutput(_ image: CIImage)
}

public class Camera: NSObject {
	public func shoot() {
		let s = AVCapturePhotoSettings(from: session.photoSettings)
		session.photoOutput.capturePhoto(with: s, delegate: self)
	}

	public func `switch`() { session.switch() }

	public func start() { if cameraAvailable { startSession() } }
	public func stop() { if cameraAvailable { session.stop() } }
	
	func startSession() {
		view.layer.addSublayer(session.layer)
		session.start()
	}

	public init(in view: UIImageView) {
		super.init()
		self.view = view
	}

	public weak var delegate: CameraDelegate?
	var cameraAvailable: Bool { return UIImagePickerController.isSourceTypeAvailable(.camera) }
	lazy var session = CameraSession()
	weak var view: UIImageView!
}


extension Camera: AVCapturePhotoCaptureDelegate {
	public func photoOutput(_ output: AVCapturePhotoOutput, didCapturePhotoFor resolvedSettings: AVCaptureResolvedPhotoSettings) {
		DispatchQueue.main.async() { [unowned self] in
			self.view.layer.sublayers?.removeSubrange(1...)
		}
	}
	
	public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let e = error { print("Camera failed: \(e.localizedDescription)") }
		else {
			if let cgi = photo.cgImageRepresentation()?.takeUnretainedValue() {
				delegate?.cameraOutput(CIImage(cgImage: cgi))
			}
		}
	}
}

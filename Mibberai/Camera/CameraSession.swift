import UIKit
import AVFoundation

public class CameraSession: NSObject {
	public func start() {
		if let i = input {
			session.addInput(i)
			session.startRunning()
		}
	}
	
	public func stop() {
		session.stopRunning()
		clearInput()
	}
	
	public func `switch`() {
		stop()
		if position == .back { position = .front }
		else { position = .back }
		start()
	}
	
	func clearInput() {
		if let si = session.inputs as? [AVCaptureDeviceInput] {
			for i in si { session.removeInput(i) }
		}
	}

	public lazy var layer: AVCaptureVideoPreviewLayer = {
		let l = AVCaptureVideoPreviewLayer(session: session)
		l.videoGravity = AVLayerVideoGravity.resizeAspectFill
		return l
	}()
	
	public lazy var videoOutput: AVCaptureVideoDataOutput = {
		let o = AVCaptureVideoDataOutput()
		o.videoSettings = [kCVPixelBufferPixelFormatTypeKey as String: Int(kCVPixelFormatType_32BGRA)]
		return o
	}()
	
	public lazy var photoOutput: AVCapturePhotoOutput = {
		let o = AVCapturePhotoOutput()
		o.isHighResolutionCaptureEnabled = true
		return o
	}()
	
	public lazy var photoSettings: AVCapturePhotoSettings = {
		let s = AVCapturePhotoSettings()
		s.isHighResolutionPhotoEnabled = true
		return s
	}()

	lazy var session: AVCaptureSession = {
		let s = AVCaptureSession()
		s.sessionPreset = .photo
		s.addOutput(videoOutput)
		s.addOutput(photoOutput)
		return s
	}()
	
	var input: AVCaptureDeviceInput? { return try? AVCaptureDeviceInput(device: deviceFor(position)!) }

	func deviceFor(_ position: AVCaptureDevice.Position) -> AVCaptureDevice? {
		return AVCaptureDevice.default(.builtInWideAngleCamera, for: AVMediaType.video, position: position)
	}
	
	var position: AVCaptureDevice.Position = .back
}

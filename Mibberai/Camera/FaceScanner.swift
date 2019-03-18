import UIKit
import AVFoundation
import Vision

public class FaceScanner: Camera {
	override public func shoot() { waitingForPhoto = true }

	override public init(in view: UIImageView) {
		super.init(in: view)
		observer.delegate = self
	}
	
	override func startSession() {
		session.position = .front
		session.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
		super.startSession()
	}
	
	lazy var observer = VisionObserver()
	
	lazy var highlighter = FaceHighlighter(view: view, delegate: self)
	let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
	var waitingForPhoto = false
}


extension FaceScanner: VisionObserverDelegate {
	public func observerOutput(_ observations: [Any]) {}
}


extension FaceScanner {
	override public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		super.photoOutput(output, didFinishProcessingPhoto: photo, error: error)
	}
}


extension FaceScanner: HighlighterDelegate {
	public func highlightFound() {
		if waitingForPhoto {
			let s = AVCapturePhotoSettings(from: session.photoSettings)
			session.photoOutput.capturePhoto(with: s, delegate: self)
			waitingForPhoto = false
		}
	}
}


extension FaceScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
	public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if waitingForPhoto {
			highlighter.execute(using: sampleBuffer)
		}
	}
}

import UIKit
import AVFoundation
import Vision

public class DocumentScanner: Camera {	
	override public init(in view: UIImageView) {
		super.init(in: view)
		observer.delegate = self
	}
	
	public func crop(_ image: CGImage, tight: Bool) {
		fullScan = image
		let rr: VNDetectRectanglesRequest = {
			if tight { return observer.tightRectangleRequest}
			else { return observer.rectangleRequest}
		}()
		observer.execute(requests: [rr], onCGImage: image)
	}
	
	override func startSession() {
		session.videoOutput.setSampleBufferDelegate(self, queue: DispatchQueue.global(qos: .userInteractive))
		super.startSession()
	}
	
	lazy var observer = VisionObserver()
	var fullScan: CGImage?
	
	lazy var highlighter = RectangleHighlighter(view: view, delegate: self)
	let perspectiveCorrection = CIFilter(name: "CIPerspectiveCorrection")!
	var waitingForPhoto = true
}


extension DocumentScanner: VisionObserverDelegate {
	public func observerOutput(_ observations: [Any]) {
		if let fs = fullScan {
			if let o = observations.first as? VNRectangleObservation {
				if let s = correct(image: fs, with: o)?.adjust(ev: 0.5)?.sharpen(to: 0.5) {
					delegate?.cameraOutput(s)
				}
			}
			else { delegate?.cameraOutput(CIImage(cgImage: fs)) }
		}
		
		fullScan = nil
	}
	
	func correct(image: CGImage, with observation: VNRectangleObservation) -> CIImage? {
		let s = CGSize(width: image.width, height: image.height)
		
		let tl = observation.topLeft.scaled(to: s)
		let tr = observation.topRight.scaled(to: s)
		let br = observation.bottomRight.scaled(to: s)
		let bl = observation.bottomLeft.scaled(to: s)
		
		let cii = CIImage(cgImage: image)
		
		perspectiveCorrection.setValue(cii, forKey: kCIInputImageKey)
		perspectiveCorrection.setValue(CIVector(cgPoint: bl), forKey: "inputTopLeft")
		perspectiveCorrection.setValue(CIVector(cgPoint: tl), forKey: "inputTopRight")
		perspectiveCorrection.setValue(CIVector(cgPoint: tr), forKey: "inputBottomRight")
		perspectiveCorrection.setValue(CIVector(cgPoint: br), forKey: "inputBottomLeft")
		
		return perspectiveCorrection.outputImage!
	}
}


extension DocumentScanner {
	override public func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
		if let e = error { print("Document Scanner failed: \(e.localizedDescription)")
		} else {
			if let cgi = photo.cgImageRepresentation()?.takeUnretainedValue() {
				crop(cgi, tight: true)
				waitingForPhoto = true
			}
		}
	}
}


extension DocumentScanner: HighlighterDelegate {
	public func highlightFound() {
		if waitingForPhoto {
			let s = AVCapturePhotoSettings(from: session.photoSettings)
			session.photoOutput.capturePhoto(with: s, delegate: self)			
			waitingForPhoto = false
		}
	}
}


extension DocumentScanner: AVCaptureVideoDataOutputSampleBufferDelegate {
	public func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
		if waitingForPhoto {
			highlighter.execute(using: sampleBuffer)
		}
	}
}

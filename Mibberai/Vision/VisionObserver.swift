import AVFoundation
import Vision

public protocol VisionObserverDelegate: class {
	func observerOutput(_ observations: [Any])
}

public class VisionObserver {
	public func execute(requests: [VNImageBasedRequest], onCGImage cgImage: CGImage) {
		execute(requests: requests, onCGImage: cgImage, orientation: .up)
	}

	public func execute(requests: [VNImageBasedRequest], onCGImage cgImage: CGImage, orientation: CGImagePropertyOrientation) {
		let requestOptions: [VNImageOption : Any] = [:]
		let irh = VNImageRequestHandler(cgImage: cgImage, orientation: orientation, options: requestOptions)
		do { try irh.perform(requests) }
		catch { print(error) }
	}

	public func execute(requests: [VNImageBasedRequest], onBuffer buffer: CMSampleBuffer) {
		guard let ib = CMSampleBufferGetImageBuffer(buffer) else { return }
		
		var requestOptions:[VNImageOption : Any] = [:]
		if let camData = CMGetAttachment(buffer, key: kCMSampleBufferAttachmentKey_CameraIntrinsicMatrix, attachmentModeOut: nil) {
			requestOptions = [.cameraIntrinsics: camData]
		}		
		let irh = VNImageRequestHandler(cvPixelBuffer: ib, orientation: .rightMirrored, options: requestOptions)
		do { try irh.perform(requests) }
		catch { print(error) }
	}

	public lazy var tightRectangleRequest: VNDetectRectanglesRequest = {
		let r = VNDetectRectanglesRequest(completionHandler: detectionHandler)
		r.quadratureTolerance = 4
		r.minimumSize = 0.45
		return r
	}()

	public lazy var textRequest: VNDetectTextRectanglesRequest = {
		let r = VNDetectTextRectanglesRequest(completionHandler: detectionHandler)
		r.reportCharacterBoxes = true
		return r
	}()

	public lazy var rectangleRequest: VNDetectRectanglesRequest = { return VNDetectRectanglesRequest(completionHandler: detectionHandler) }()
	public lazy var faceRectangleRequest: VNDetectFaceRectanglesRequest = { return VNDetectFaceRectanglesRequest(completionHandler: detectionHandler) }()
	public lazy var faceLandmarkRequest: VNDetectFaceLandmarksRequest = { return VNDetectFaceLandmarksRequest(completionHandler: detectionHandler) }()

	func detectionHandler(request: VNRequest, error: Error?) {
		if let r = request.results {
			if let d = delegate {
				DispatchQueue.main.async() { d.observerOutput(r) }
			}
		}
	}

	public var delegate: VisionObserverDelegate?
	public init() {}
}


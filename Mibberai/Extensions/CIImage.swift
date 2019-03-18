import Foundation

extension CIImage {
	public var optimisedForOCR: CIImage? {
		return control(saturation: 0.0, brightness: 0.0, contrast: 1.3)
	}

	public func control(saturation: CGFloat, brightness: CGFloat, contrast: CGFloat) -> CIImage? {
		return CIFilter(name:"CIColorControls", parameters: [kCIInputImageKey: self, kCIInputSaturationKey: saturation, kCIInputBrightnessKey: brightness, kCIInputContrastKey: contrast])?.outputImage
	}

	public func adjust(ev: Double) -> CIImage? {
			return CIFilter(name:"CIExposureAdjust", parameters: [kCIInputImageKey: self, kCIInputEVKey: ev])?.outputImage
	}

	public func sharpen(to: Double) -> CIImage? {
		return CIFilter(name:"CISharpenLuminance", parameters: [kCIInputImageKey: self, kCIInputSharpnessKey: to])?.outputImage
	}

	public var uiImage: UIImage {
		let cg = cgImage
		return UIImage.init(cgImage: cg)
	}
	
	public var cgImage: CGImage {
		let c = CIContext(options: nil)
		return c.createCGImage(self, from: extent)!
	}
}

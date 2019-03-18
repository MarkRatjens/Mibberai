import Foundation

extension UIImage {
	public var cgImage: CGImage {
		let ci = CIImage(image: self)!
		return ci.cgImage
	}
	
	public var orientedLeft: UIImage {
		var o: UIImage.Orientation
		
		switch self.imageOrientation {
		case .left:
			o = UIImage.Orientation.down
		case .up:
			o = UIImage.Orientation.left
		case .down:
			o = UIImage.Orientation.right
		default:
			o = UIImage.Orientation.up
		}
		
		return UIImage(cgImage: cgImage, scale: scale, orientation: o)
	}
	
	public var orientedRight: UIImage {
		var o: UIImage.Orientation
		
		switch self.imageOrientation {
		case .right:
			o = UIImage.Orientation.down
		case .up:
			o = UIImage.Orientation.right
		case .down:
			o = UIImage.Orientation.left
		default:
			o = UIImage.Orientation.up
		}
		
		return UIImage(cgImage: cgImage, scale: scale, orientation: o)
	}

	public func scale(by ratio: CGFloat) -> UIImage {
		let s = self.size
		let ns = CGSize(width: s.width * ratio, height: s.height * ratio)
		let r = CGRect(x: 0, y: 0, width: ns.width, height: ns.height)
		
		UIGraphicsBeginImageContextWithOptions(ns, false, 1.0)
		draw(in: r)
		let i = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()
		
		return i!
	}
	
	public func scale(to maximum: CGFloat) -> UIImage {
		var s = CGSize(width: maximum, height: maximum)
		
		if size.width > size.height { s.height = s.width * size.height / size.width }
		else { s.width = s.height * size.width / size.height }

		UIGraphicsBeginImageContext(s)
		draw(in: CGRect(origin: .zero, size: s))
		let i = UIGraphicsGetImageFromCurrentImageContext()
		UIGraphicsEndImageContext()		
		return i ?? self
	}

	public var squareLeft: UIImage {
		let w = size.width
		let h = size.height
		
		let s =  CGSize(width: h, height: w)
		
		UIGraphicsBeginImageContext(s)
		let c = UIGraphicsGetCurrentContext()!
		
		c.translateBy(x: s.width / 2, y: s.height / 2)
		c.rotate(by: -.pi / 2)
		c.scaleBy(x: 1.0, y: -1.0)
		c.draw(cgImage, in: CGRect(x: -w / 2,  y: -h / 2, width: w, height: w))
		
		let i = UIGraphicsGetImageFromCurrentImageContext()!

		UIGraphicsEndImageContext()
		
		return i
	}

	public var squareRight: UIImage {
		let w = size.width
		let h = size.height
		
		let s =  CGSize(width: h, height: w)
		
		UIGraphicsBeginImageContext(s)
		let c = UIGraphicsGetCurrentContext()!
		
		c.translateBy(x: s.width / 2, y: s.height / 2)
		c.rotate(by: .pi / 2)
		c.scaleBy(x: 1.0, y: -1.0)
		c.draw(cgImage, in: CGRect(x: -w / 2,  y: -h / 2, width: w, height: w))
		
		let i = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		
		return i
	}

	public var square180: UIImage {
		let w = size.width
		let h = size.height
		
		let s =  CGSize(width: w, height: h)
		
		UIGraphicsBeginImageContext(s)
		let c = UIGraphicsGetCurrentContext()!
		
		c.translateBy(x: s.width / 2, y: s.height / 2)
		c.rotate(by: .pi)
		c.scaleBy(x: 1.0, y: -1.0)
		c.draw(cgImage, in: CGRect(x: -w / 2,  y: -h / 2, width: w, height: w))
		
		let i = UIGraphicsGetImageFromCurrentImageContext()!
		
		UIGraphicsEndImageContext()
		
		return i
	}
	
	public var forOCR: CGImage? {
		guard let cii = CIImage(image: self)?.optimisedForOCR else { return nil }
		
		let c = CIContext(options: nil)
		return c.createCGImage(cii, from: cii.extent)
	}
}

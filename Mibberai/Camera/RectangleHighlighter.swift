import Yarngun
import Vision
import AVFoundation

public class RectangleHighlighter: Highlighter {
	public func execute(using buffer: CMSampleBuffer) {
		observer.delegate = self		
		observer.execute(requests: [observer.tightRectangleRequest], onBuffer: buffer)
	}
}

extension RectangleHighlighter: VisionObserverDelegate {
	public func observerOutput(_ observations: [Any]) {
		if let o = observations.first as? VNRectangleObservation { highlight(o) }
	}
	
	func highlight(_ observation: VNRectangleObservation) {
		let r = observation
		
		if r.onScreen() && r.tight() {
			delegate?.highlightFound()

			if let v = self.view {
				let f = v.frame
				let s = f.size
				
				let tl = r.topLeft.scaled(to: s)
				let tr = r.topRight.scaled(to: s)
				let br = r.bottomRight.scaled(to: s)
				let bl = r.bottomLeft.scaled(to: s)
				
				let p = UIBezierPath()
				p.move(to: tl)
				p.addLine(to: tr)
				p.addLine(to: br)
				p.addLine(to: bl)
				p.close()
				
				let sa = CAShapeLayer()
				sa.path = p.cgPath
				sa.opacity = 0.4
			
				v.layer.addSublayer(sa)
			}
		}
	}
}

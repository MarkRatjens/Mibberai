import Vision

extension VNRectangleObservation {
	public func onScreen() -> Bool {
		return topLeft.x > 0.02 && bottomLeft.x > 0.02 &&
			topRight.x < 0.98 && bottomRight.x < 0.98 &&
			bottomLeft.y > 0.02 && bottomRight.y > 0.02 &&
			topLeft.y < 0.98 && topRight.y < 0.98
	}
	
	public func tight() -> Bool {
		return (topLeft.x < 0.15 && bottomLeft.x < 0.15 && topRight.x > 0.85 && bottomRight.x > 0.85) ||
			(bottomLeft.y < 0.10 && bottomRight.y < 0.10 && topLeft.y > 0.90 && topRight.y > 0.90)
	}
}

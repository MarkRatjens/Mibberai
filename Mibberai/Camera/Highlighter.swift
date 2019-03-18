import UIKit
import AVFoundation
import Vision

public protocol HighlighterDelegate: class {
	func highlightFound()
}

public class Highlighter {
	public init(view: UIImageView, delegate: HighlighterDelegate ) {
		self.view = view
		self.delegate = delegate
	}
	
	weak var view: UIImageView?
	weak var delegate: HighlighterDelegate?
	lazy var observer = VisionObserver()
}

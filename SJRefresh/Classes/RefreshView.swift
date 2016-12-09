//
//  RefreshView.swift
//  Pods
//
//  Created by Subins Jose on 05/10/16.
//  Copyright © 2016 Subins Jose. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software
//    and associated documentation files (the "Software"), to deal in the Software without
//	  restriction, including without limitation the rights to use, copy, modify, merge, publish,
//    distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom
//	  the Software is furnished to do so, subject to the following conditions:
//
//  The above copyright notice and this permission notice shall be included in all copies or
//    substantial portions of the Software.
//
//  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING
//  BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE
//  AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
//  CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
//  FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import UIKit

let contentOffsetKeyPath = "contentOffset"
var kvoContext = "PullToRefreshKVOContext"

typealias AnimationCompleteCallback = (_ percentage: CGFloat) -> Void
typealias RefreshCompletionCallback = (Void) -> Void

class RefreshView: UIView {

	// MARK: Variables
	var refreshCompletion: RefreshCompletionCallback?
	let bendDistance: CGFloat = 50.0
	var waveLayer: CAShapeLayer?
	var ballView: BallView?

	// MARK: UIView
	override convenience init(frame: CGRect) {

		self.init(refreshCompletion: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}

	init(refreshCompletion: RefreshCompletionCallback?) {

		self.refreshCompletion = refreshCompletion
		let height: CGFloat = 120.0
		let refreshViewFrame = CGRect(x: 0,
		                              y: -height,
		                              width: UIScreen.main.bounds.width,
		                              height: height)

		super.init(frame: refreshViewFrame)
		frame = refreshViewFrame

		let ballViewHeight: CGFloat = 56
		ballView = BallView(
			frame: CGRect(x: 0, y: 50, width: frame.width, height: ballViewHeight),
			circleSize: 28,
			timingFunc: CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseOut),
			moveUpDuration: 0.2,
			moveUpDist: 53,
			color: UIColor.white)
		addSubview(ballView!)
		ballView?.isHidden = true
	}

	func addPullWave() {

		backgroundColor = UIColor(red: 0.38,
		                          green: 0.64,
		                          blue: 0.95,
		                          alpha: 1)
		waveLayer = CAShapeLayer(layer: self.layer)
		waveLayer?.lineWidth = 1
		waveLayer?.path = wavePath(0.0, amountY: 0.0)
		waveLayer?.strokeColor = backgroundColor?.cgColor
		waveLayer?.fillColor = backgroundColor?.cgColor
		superview?.layer.addSublayer(waveLayer!)
	}

	func wavePath(_ amountX:CGFloat, amountY:CGFloat) -> CGPath {

		let w = self.frame.width
		let centerY:CGFloat = 0

		let topLeftPoint = CGPoint(x: 0, y: centerY)
		let topMidPoint = CGPoint(x: w / 2 + amountX, y: centerY + amountY)
		let topRightPoint = CGPoint(x: w, y: centerY)

		let bezierPath = UIBezierPath()
		bezierPath.move(to: topLeftPoint)
		bezierPath.addQuadCurve(to: topRightPoint, controlPoint: topMidPoint)
		return bezierPath.cgPath
	}

	override func willMove(toSuperview superView: UIView!) {

		self.removeRegister()
		guard let scrollView = superView as? UIScrollView else {
			return
		}
		scrollView.addObserver(self,
		                       forKeyPath: contentOffsetKeyPath,
		                       options: .initial,
		                       context: &kvoContext)
	}

	func removeRegister() {

		if let scrollView = superview as? UIScrollView {
			scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
		}
	}

	deinit {

		self.removeRegister()
	}

	func boundAnimation(positionX: CGFloat,positionY: CGFloat) {

		waveLayer?.path = wavePath(0, amountY: 0)
		let bounce = CAKeyframeAnimation(keyPath: "path")
		bounce.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseIn)
		let values = [
			self.wavePath(positionX, amountY: positionY),
			self.wavePath(-(positionX * 0.7), amountY: -(positionY * 0.7)),
			self.wavePath(positionX * 0.6, amountY: positionY * 0.6),
			self.wavePath(-(positionX * 0.5), amountY: -(positionY * 0.5)),
			self.wavePath(positionX * 0.4, amountY: positionY * 0.4),
			self.wavePath(-(positionX * 0.3), amountY: -(positionY * 0.3)),
			self.wavePath(positionX * 0.15, amountY: positionY * 0.15),
			self.wavePath(0.0, amountY: 0.0)
		]
		bounce.values = values
		bounce.duration = 0.4
		bounce.isRemovedOnCompletion = true
		bounce.fillMode = kCAFillModeForwards
		waveLayer?.add(bounce, forKey: "return")

		
		Timer.scheduledTimer(timeInterval: 0.2, target: self,
		                     selector: #selector(self.ballAnimation),
		                     userInfo: nil,
		                     repeats: false)
		refreshCompletion?()
	}

	func ballAnimation() {

		ballView?.isHidden = false
		ballView?.startAnimation()
	}

	// MARK: KVO
	override func observeValue(forKeyPath keyPath: String?, of object: Any?,
	                           change: [NSKeyValueChangeKey : Any]?,
	                           context: UnsafeMutableRawPointer?) {

		guard let scrollView = object as? UIScrollView else {
			return
		}

		if !(context == &kvoContext && keyPath == contentOffsetKeyPath) {
			
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}

		if scrollView.contentOffset.y < 0 {

			let pullDistance = (frame.size.height - bendDistance)
			let offsetY = abs(scrollView.contentOffset.y)

			if offsetY > pullDistance {
				waveLayer?.path = wavePath(0, amountY: (offsetY - pullDistance))

				if offsetY > frame.size.height {
					scrollView.isScrollEnabled = false
					scrollView.setContentOffset(CGPoint(x: scrollView.contentOffset.x,
					                                    y: -frame.size.height),
					                            animated: false)
					boundAnimation(positionX: 0, positionY: bendDistance)
				}
			} else {
				waveLayer?.path = wavePath(0, amountY: 0)
			}
		}
	}
}

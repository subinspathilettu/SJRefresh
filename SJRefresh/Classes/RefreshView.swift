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
let contentSizeKeyPath = "contentSize"
var kvoContext = "PullToRefreshKVOContext"

typealias AnimationCompleteCallback = (_ percentage: CGFloat) -> Void
typealias RefreshCompletionCallback = (Void) -> Void

class RefreshView: UIView {

	// MARK: Variables
	fileprivate var refreshCompletion: RefreshCompletionCallback?
	fileprivate var animationCompletion: AnimationCompleteCallback?
	fileprivate var arrow: UIImageView?
	fileprivate var animationView: UIImageView?
	fileprivate var animationPercentage: CGFloat = 0.0
	fileprivate let animationDuration: Double = 0.5
	fileprivate var scrollViewBounces = false
	fileprivate var scrollViewInsets = UIEdgeInsets.zero

	internal var options: RefreshViewOptions
	internal var percentage: CGFloat = 0.0 {
		didSet {
			self.startAnimation()
		}
	}

	internal var state = PullToRefreshState.pulling {
		didSet {

			if self.state == oldValue || animationView?.animationImages?.count == 0 {
				return
			}
			switch self.state {
			case .stop:
				stopAnimating()
			case .finish:
				var time = DispatchTime.now() +
					Double(Int64(animationDuration *
						Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
				DispatchQueue.main.asyncAfter(deadline: time) {
					self.stopAnimating()
				}

				time = DispatchTime.now() +
					Double(Int64((animationDuration * 2) *
						Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
				DispatchQueue.main.asyncAfter(deadline: time) {
					self.removeFromSuperview()
				}
			case .refreshing:
				startAnimating()
			case .pulling, .triggered:
				rotatePullImage(state)
			}
		}
	}

	// MARK: UIView
	override convenience init(frame: CGRect) {

		self.init(options: RefreshViewOptions(),
		          refreshCompletion:nil)
	}

	required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	init(options: RefreshViewOptions,
	     refreshCompletion: RefreshCompletionCallback?) {

		let refreshViewFrame = CGRect(x: 0,
		                              y: -options.viewHeight,
		                              width: UIScreen.main.bounds.width,
		                              height: options.viewHeight)

		self.options = options
		self.refreshCompletion = refreshCompletion

		if options.pullImage != nil {
			arrow = UIImageView.init(image: UIImage(named: options.pullImage!))
			arrow?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
		}

		let animationImages = RefreshView.getAnimationImages(options)
		var animationframe = CGRect.zero

		if !animationImages.isEmpty {
			animationframe.size.width = animationImages[0].size.width
			animationframe.size.height = animationImages[0].size.height
		}

		animationView = UIImageView(frame: animationframe)
		animationView?.animationImages = animationImages
		animationView?.contentMode = .scaleAspectFit
		animationView?.animationDuration = 0.5
		animationView?.isHidden = true

		super.init(frame: refreshViewFrame)
		self.frame = refreshViewFrame
		addSubview(animationView!)

		if arrow != nil {
			addSubview(arrow!)
		}
		autoresizingMask = .flexibleWidth
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let center = CGPoint(x: UIScreen.main.bounds.size.width / 2,
		                     y: self.frame.size.height / 2)
		self.arrow?.center = center
		self.arrow?.frame = (arrow?.frame.offsetBy(dx: 0, dy: 0))!

		animationView?.center = center
	}

	override func willMove(toSuperview superView: UIView!) {
		//superview NOT superView, DO NEED to call the following method
		//superview dealloc will call into this when my own dealloc run later!!
		self.removeRegister()
		guard let scrollView = superView as? UIScrollView else {
			return
		}
		scrollView.addObserver(self,
		                       forKeyPath: contentOffsetKeyPath,
		                       options: .initial,
		                       context: &kvoContext)
	}

	func animateImages(_ percentage: CGFloat) {

		if percentage != 0 && percentage > animationPercentage {
			startAnimation({ (percentage) in
				self.animationPercentage = percentage
				if percentage >= 100 {
					self.stopAnimating()
				} else {
					self.startAnimation()
				}
			})
		}
	}

	func startAnimation() {

		if animationPercentage < percentage && percentage != 0 {
			startAnimation({ (percent) in
				self.animationPercentage = percent
				if percent >= 100 {
					self.stopAnimating()
				} else {
					self.startAnimation()
				}
			})
		}
	}

	func removeRegister() {

		if let scrollView = superview as? UIScrollView {
			scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
		}
	}

	deinit {

		self.removeRegister()
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

		// Pulling State Check
		let offsetY = scrollView.contentOffset.y
		if offsetY <= 0 {
			if offsetY < -self.frame.size.height {
				// pulling or refreshing
				if scrollView.isDragging == false && self.state != .refreshing { //release the finger
					self.state = .refreshing //startAnimating
				} else if self.state != .refreshing { //reach the threshold
					self.state = .triggered
				}
			} else if self.state == .triggered {
				//starting point, start from pulling
				self.state = .pulling
			}
			return //return for pull down
		}

		//push up
		let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
		if upHeight > 0 {
			return
		}
	}

	class func getAnimationImages(_ options: RefreshViewOptions) -> [UIImage] {

		var animationImages = options.animationImages
		if let gifImage = options.gifImage {

			animationImages = UIImage.imagesFromGif(name: gifImage)
		}

		if animationImages == nil {
			print("Neither RefreshViewOptions.gifImage nor" +
				" RefreshViewOptions.animationImages should not be nil")
			animationImages = [UIImage]()
		}
		return animationImages!
	}

	func startAnimating() {

		animationView?.isHidden = false
		startAnimation(nil)

		self.arrow?.isHidden = true
		guard let scrollView = superview as? UIScrollView else {
			return
		}
		scrollViewBounces = scrollView.bounces
		scrollViewInsets = scrollView.contentInset
		var insets = scrollView.contentInset
		insets.top += self.frame.size.height

		scrollView.bounces = false
		UIView.animate(withDuration: animationDuration, delay: 0,
		               options:[], animations: {
						scrollView.contentInset = insets
			},
		               completion: { _ in

						self.refreshCompletion?()
		})
	}

	func getAnimationStartIndex(_ completedPercentage: CGFloat) -> Int {

		var percentage = completedPercentage
		if percentage > self.percentage {
			percentage = self.percentage
		}
		let count = animationView?.animationImages?.count
		let index = options.definite ? Int(CGFloat(count!) * (percentage / 100.0)) : 0
		return Int(index)
	}

	func getAnimationEndIndex(_ options: RefreshViewOptions,
	                          percentage: CGFloat) -> Int {

		let count = animationView?.animationImages?.count
		let index = options.definite ? Int(CGFloat(count!) * (percentage / 100.0)) : count!
		return Int(index)
	}

	func getAnimationImages(_ percentage: CGFloat) -> [CGImage] {

		var images = [CGImage]()
		let startIndex = getAnimationStartIndex(animationPercentage)
		let endIndex = getAnimationEndIndex(options, percentage: percentage)

		for index in startIndex..<endIndex {
			let image = animationView?.animationImages?[index]
			images.append((image?.cgImage!)!)
		}

		return images
	}

	func startAnimation(_ callback: AnimationCompleteCallback?) {

		animationCompletion = callback
		let animation = CAKeyframeAnimation()
		animation.keyPath = "contents"
		animation.values = getAnimationImages(percentage)
		animation.repeatCount = options.definite ? 0.0 : Float.infinity
		animation.duration = animationDuration
		animation.delegate = self

		animationView?.layer.add(animation, forKey: "contents")
		var index = getAnimationEndIndex(options,
		                                 percentage: percentage)
		index = index > 0 ? index - 1 : index
		animationView?.image = animationView?.animationImages?[index]
		animationPercentage = percentage
	}

	func stopAnimating() {

		animationPercentage = 0.0
		percentage = 0.0
		animationView?.isHidden = true
		animationView?.stopAnimating()
		arrow?.isHidden = false
		guard let scrollView = superview as? UIScrollView else {
			return
		}
		scrollView.bounces = self.scrollViewBounces
		UIView.animate(withDuration: animationDuration,
		               animations: {
						scrollView.contentInset = self.scrollViewInsets
						self.arrow?.transform = CGAffineTransform.identity
			}, completion: { _ in
				self.state = .pulling
			}
		)
	}

	func rotatePullImage(_ state: PullToRefreshState) {

		UIView.animate(withDuration: 0.2, animations: {
			var transform = CGAffineTransform.identity
			if state == PullToRefreshState.triggered {
				transform = CGAffineTransform(rotationAngle: CGFloat(M_PI))
			}
			self.arrow?.transform = transform
		})
	}
}

extension RefreshView: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {
		
		animationCompletion?(animationPercentage)
	}
}

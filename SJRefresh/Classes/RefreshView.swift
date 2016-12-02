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
	var refreshCompletion: RefreshCompletionCallback?
	var animationCompletion: AnimationCompleteCallback?
	var pullImageView = UIImageView()
	var animationView = UIImageView()
	var animationPercentage: CGFloat = 0.0
	let animationDuration: Double = 0.5
	var scrollViewBounces = false
	var scrollViewInsets = UIEdgeInsets.zero
	var percentage: CGFloat = 0.0 {
		didSet {
			self.startAnimation()
		}
	}

	var isDefinite = false
	var state = SJRefreshState.pulling {
		didSet {

			if self.state == oldValue || animationView.animationImages?.count == 0 {
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
			case .pulling, .triggered: break
			}
		}
	}

	// MARK: UIView
	override convenience init(frame: CGRect) {

		self.init(refreshCompletion: nil)
	}

	required init?(coder aDecoder: NSCoder) {
		
		super.init(coder: aDecoder)
	}

	init(refreshCompletion: RefreshCompletionCallback?) {

		self.refreshCompletion = refreshCompletion

		precondition(SJRefresh.shared.theme != nil, "Provide a theme")

		var height: CGFloat = 0.0
		if let viewHeight = SJRefresh.shared.theme?.heightForRefreshView() {
			height = viewHeight
		}

		let refreshViewFrame = CGRect(x: 0,
		                              y: -height,
		                              width: UIScreen.main.bounds.width,
		                              height: height)

		super.init(frame: refreshViewFrame)
		frame = refreshViewFrame
		setRefreshView()
	}

	override func layoutSubviews() {

		super.layoutSubviews()
		let center = CGPoint(x: UIScreen.main.bounds.size.width / 2,
		                     y: self.frame.size.height / 2)
		pullImageView.center = center
		pullImageView.frame = pullImageView.frame.offsetBy(dx: 0, dy: 0)
		pullImageView.backgroundColor = .clear
		animationView.center = center
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

	func setRefreshView() {

		loadBackgroundImageView()
		loadPullToRefreshArrowView()
		loadAnimationView()
		autoresizingMask = .flexibleWidth
	}

	func loadBackgroundImageView() {

		let backgroundView = UIImageView(frame: self.bounds)
		backgroundView.backgroundColor = SJRefresh.shared.theme?.backgroundColorForRefreshView()

		if let image = SJRefresh.shared.theme?.backgroundImageForRefreshView() {
			backgroundView.image = image
		}
		backgroundView.contentMode = .scaleAspectFill
		addSubview(backgroundView)
	}

	func loadPullToRefreshArrowView() {

		pullImageView.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
		addSubview(pullImageView)
	}

	func loadAnimationView() {

		if let animationImages = SJRefresh.shared.theme?.imagesForRefreshViewLoadingAnimation() {

			var animationframe = CGRect.zero

			if !animationImages.isEmpty {
				animationframe.size.width = animationImages[0].size.width
				animationframe.size.height = animationImages[0].size.height
			}

			animationView = UIImageView(frame: animationframe)
			animationView.animationImages = animationImages
			animationView.contentMode = .scaleAspectFit
			animationView.animationDuration = 0.5
			animationView.isHidden = true
			animationView.backgroundColor = .clear
			addSubview(animationView)
		}
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

			if let pullImage = SJRefresh.shared.theme?.pullImageForRefreshView(state: state,
			                                                                   pullPercentage: 0.0) {
				pullImageView.image = pullImage
				pullImageView.frame.size = pullImage.size
			}

			return //return for pull down
		}

		//push up
		let upHeight = offsetY + scrollView.frame.size.height - scrollView.contentSize.height
		if upHeight > 0 {
			return
		}
	}

	func startAnimating() {

		animationView.isHidden = false
		startAnimation(nil)

		pullImageView.isHidden = true
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
		let count = animationView.animationImages?.count
		let index = isDefinite ? Int(CGFloat(count!) * (percentage / 100.0)) : 0
		return Int(index)
	}

	func getAnimationEndIndex(_ percentage: CGFloat) -> Int {

		let count = animationView.animationImages?.count
		let index = isDefinite ? Int(CGFloat(count!) * (percentage / 100.0)) : count!
		return Int(index)
	}

	func getAnimationImages(_ percentage: CGFloat) -> [CGImage] {

		var images = [CGImage]()
		let startIndex = getAnimationStartIndex(animationPercentage)
		let endIndex = getAnimationEndIndex(percentage)

		for index in startIndex..<endIndex {
			let image = animationView.animationImages?[index]
			images.append((image?.cgImage!)!)
		}
		
		return images
	}
}

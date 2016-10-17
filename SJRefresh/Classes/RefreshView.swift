//
//  RefreshView.swift
//  Pods
//
//  Created by Subins Jose on 05/10/16.
//  Copyright © 2016 Subins Jose. All rights reserved.
//
//  Permission is hereby granted, free of charge, to any person obtaining a copy of this software and
//    associated documentation files (the "Software"), to deal in the Software without restriction,
//    including without limitation the rights to use, copy, modify, merge, publish, distribute,
//    sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is
//    furnished to do so, subject to the following conditions:
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

enum RefreshType {

	case Default, Custom
}

class RefreshView: UIView {

	enum PullToRefreshState {

		case pulling
		case triggered
		case refreshing
		case stop
		case finish
	}

	// MARK: Variables
	let contentOffsetKeyPath = "contentOffset"
	let contentSizeKeyPath = "contentSize"
	var kvoContext = "PullToRefreshKVOContext"
	var type = RefreshType.Default
	var options: RefreshViewOptions
	var arrow: UIImageView?
	var indicator: UIActivityIndicatorView?
	var animationView: UIImageView?
	var scrollViewBounces: Bool = false
	var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
	var refreshCompletion: ((Void) -> Void)?
	let animationDuration: Double = 0.5

	var state: PullToRefreshState = PullToRefreshState.pulling {
		didSet {
			if self.state == oldValue {
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
			case .pulling: //starting point
				arrowRotationBack()
			case .triggered:
				arrowRotation()
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
	     refreshCompletion :((Void) -> Void)?) {

		let refreshViewFrame = CGRect(x: 0,
		                              y: -options.viewHeight,
		                              width: UIScreen.main.bounds.width,
		                              height: options.viewHeight)

		self.options = options
		self.refreshCompletion = refreshCompletion

		arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
		arrow?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]

		if options.pullImage != nil {
			arrow?.image = UIImage(named: options.pullImage!)
		}

		let animationImages = RefreshView.getAnimationImages(options)
		if animationImages.isEmpty {

			indicator = UIActivityIndicatorView(activityIndicatorStyle:
				UIActivityIndicatorViewStyle.gray)
			indicator?.bounds = (arrow?.bounds)!
			indicator?.autoresizingMask = (arrow?.autoresizingMask)!
			indicator?.hidesWhenStopped = true
			indicator?.color = options.indicatorColor
			type = .Default
		} else {

			var animationframe = CGRect.zero
			animationframe.size.width = animationImages[0].size.width
			animationframe.size.height = animationImages[0].size.height

			animationView = UIImageView(frame: animationframe)
			animationView?.animationImages = animationImages
			animationView?.contentMode = .scaleAspectFit
			animationView?.animationDuration = 0.5
			animationView?.isHidden = true
			type = .Custom
		}

		super.init(frame: refreshViewFrame)

		self.frame = refreshViewFrame

		type == .Default ? addSubview(indicator!) : addSubview(animationView!)

		if arrow != nil {
			addSubview(arrow!)
		}
		autoresizingMask = .flexibleWidth
	}

	override func layoutSubviews() {
		super.layoutSubviews()
		let center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: self.frame.size.height / 2)
		self.arrow?.center = center
		self.arrow?.frame = (arrow?.frame.offsetBy(dx: 0, dy: 0))!

		self.indicator?.center = center
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
		if let gifImage = options.gifImage  {

			animationImages = UIImage.imagesFromGif(name: gifImage)
		}

		return animationImages == nil ? [UIImage]() : animationImages!
	}

	func startAnimating() {

		switch type {
		case .Default:

			indicator?.startAnimating()
		case .Custom:

			animationView?.isHidden = false
			animationView?.startAnimating()
		}

		self.arrow?.isHidden = true
		guard let scrollView = superview as? UIScrollView else {
			return
		}
		scrollViewBounces = scrollView.bounces
		scrollViewInsets = scrollView.contentInset

		var insets = scrollView.contentInset
		insets.top += self.frame.size.height

		scrollView.bounces = false
		UIView.animate(withDuration: animationDuration,
		               delay: 0,
		               options:[],
		               animations: {
						scrollView.contentInset = insets
			},
		               completion: { _ in

						self.refreshCompletion?()
		})
	}

	func stopAnimating() {

		switch type {
		case .Default:

			indicator?.stopAnimating()
		case .Custom:

			animationView?.isHidden = true
			animationView?.stopAnimating()
		}

		self.arrow?.isHidden = false
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

	func arrowRotation() {
		UIView.animate(withDuration: 0.2, delay: 0, options:[], animations: {
			// -0.0000001 for the rotation direction control
			self.arrow?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI-0.0000001))
			}, completion:nil)
	}

	func arrowRotationBack() {
		UIView.animate(withDuration: 0.2, animations: {
			self.arrow?.transform = CGAffineTransform.identity
		})
	}
}

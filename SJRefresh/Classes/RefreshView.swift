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

public enum RefreshType {

	case Default, Custom
}

open class RefreshView: UIView {

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
	private var type = RefreshType.Default

	public var options: RefreshViewOptions
	public var backgroundView: UIView
	public var arrow: UIImageView?
	public var indicator: UIActivityIndicatorView?
	public var animationView: UIImageView?
	public var scrollViewBounces: Bool = false
	public var scrollViewInsets: UIEdgeInsets = UIEdgeInsets.zero
	public var refreshCompletion: ((Void) -> Void)?
	public var pull: Bool = true

	public var positionY:CGFloat = 0 {
		didSet {
			if self.positionY == oldValue {
				return
			}
			var frame = self.frame
			frame.origin.y = positionY
			self.frame = frame
		}
	}

	var state: PullToRefreshState = PullToRefreshState.pulling {
		didSet {
			if self.state == oldValue {
				return
			}
			switch self.state {
			case .stop:
				stopAnimating()
			case .finish:
				var duration = options.animationDuration
				var time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
				DispatchQueue.main.asyncAfter(deadline: time) {
					self.stopAnimating()
				}
				duration = duration * 2
				time = DispatchTime.now() + Double(Int64(duration * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
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
	public override convenience init(frame: CGRect) {

		self.init(options: RefreshViewOptions(),
		           pullImage: nil,
		          animationImages: [UIImage](),
			refreshCompletion:nil)
	}

	public required init?(coder aDecoder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	public init(options: RefreshViewOptions,
	            pullImage: String?,
	            animationImages: [UIImage],
	            refreshCompletion :((Void) -> Void)?, down:Bool=true) {

		let refreshViewFrame = CGRect(x: 0,
		                              y: -options.viewHeight,
		                              width: UIScreen.main.bounds.width,
		                              height: options.viewHeight)

		self.options = options
		self.refreshCompletion = refreshCompletion

		backgroundView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width,
		                                      height: options.viewHeight))
		backgroundView.backgroundColor = self.options.backgroundColor
		backgroundView.autoresizingMask = UIViewAutoresizing.flexibleWidth

		if pullImage != nil {

			arrow = UIImageView(frame: CGRect(x: 0, y: 0, width: 30, height: 30))
			arrow?.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin]
			arrow?.image = UIImage(named: pullImage!)
		}

		if animationImages.isEmpty {

			indicator = UIActivityIndicatorView(activityIndicatorStyle: UIActivityIndicatorViewStyle.gray)
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

		pull = down


		super.init(frame: refreshViewFrame)

		self.frame = refreshViewFrame

		type == .Default ? addSubview(indicator!) : addSubview(animationView!)

		addSubview(backgroundView)
		if arrow != nil {
			addSubview(arrow!)
		}
		autoresizingMask = .flexibleWidth
	}

	open override func layoutSubviews() {
		super.layoutSubviews()
		let center = CGPoint(x: UIScreen.main.bounds.size.width / 2, y: self.frame.size.height / 2)
		self.arrow?.center = center
		self.arrow?.frame = (arrow?.frame.offsetBy(dx: 0, dy: 0))!

		self.indicator?.center = center
		animationView?.center = center
	}

	open override func willMove(toSuperview superView: UIView!) {
		//superview NOT superView, DO NEED to call the following method
		//superview dealloc will call into this when my own dealloc run later!!
		self.removeRegister()
		guard let scrollView = superView as? UIScrollView else {
			return
		}
		scrollView.addObserver(self, forKeyPath: contentOffsetKeyPath, options: .initial, context: &kvoContext)
		if !pull {
			scrollView.addObserver(self, forKeyPath: contentSizeKeyPath, options: .initial, context: &kvoContext)
		}
	}

	public func removeRegister() {
		if let scrollView = superview as? UIScrollView {
			scrollView.removeObserver(self, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
			if !pull {
				scrollView.removeObserver(self, forKeyPath: contentSizeKeyPath, context: &kvoContext)
			}
		}
	}

	deinit {
		self.removeRegister()
	}

	// MARK: KVO

	open override func observeValue(forKeyPath keyPath: String?, of object: Any?,
	                                change: [NSKeyValueChangeKey : Any]?,
	                                context: UnsafeMutableRawPointer?) {
		guard let scrollView = object as? UIScrollView else {
			return
		}
		if keyPath == contentSizeKeyPath {
			self.positionY = scrollView.contentSize.height
			return
		}

		if !(context == &kvoContext && keyPath == contentOffsetKeyPath) {
			super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
			return
		}

		// Pulling State Check
		let offsetY = scrollView.contentOffset.y

		// Alpha set
		if options.alpha {
			var alpha = fabs(offsetY) / (self.frame.size.height + 40)
			if alpha > 0.8 {
				alpha = 0.8
			}
			self.arrow?.alpha = alpha
		}

		if offsetY <= 0 {
			if !self.pull {
				return
			}

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
			// pulling or refreshing
			if self.pull {
				return
			}
			if upHeight > self.frame.size.height {
				// pulling or refreshing
				if scrollView.isDragging == false && self.state != .refreshing { //release the finger
					self.state = .refreshing //startAnimating
				} else if self.state != .refreshing { //reach the threshold
					self.state = .triggered
				}
			} else if self.state == .triggered  {
				//starting point, start from pulling
				self.state = .pulling
			}
		}
	}

	// MARK: private

	public func startAnimating() {

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
		if pull {
			insets.top += self.frame.size.height
		} else {
			insets.bottom += self.frame.size.height
		}
		scrollView.bounces = false
		UIView.animate(withDuration: options.animationDuration,
		               delay: 0,
		               options:[],
		               animations: {
						scrollView.contentInset = insets
			},
		               completion: { _ in

						self.refreshCompletion?()
		})
	}

	public func stopAnimating() {

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
		let duration = options.animationDuration
		UIView.animate(withDuration: duration,
		               animations: {
						scrollView.contentInset = self.scrollViewInsets
						self.arrow?.transform = CGAffineTransform.identity
			}, completion: { _ in
				self.state = .pulling
			}
		)
	}

	public func arrowRotation() {
		UIView.animate(withDuration: 0.2, delay: 0, options:[], animations: {
			// -0.0000001 for the rotation direction control
			self.arrow?.transform = CGAffineTransform(rotationAngle: CGFloat(M_PI-0.0000001))
			}, completion:nil)
	}

	public func arrowRotationBack() {
		UIView.animate(withDuration: 0.2, animations: {
			self.arrow?.transform = CGAffineTransform.identity
		})
	}
}

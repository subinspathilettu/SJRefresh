//
//  RefreshViewAnimationDelegate.swift
//  Pods
//
//  Created by Subins Jose on 03/11/16.
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

import Foundation

extension RefreshView {

	func startAnimation(_ callback: AnimationCompleteCallback?) {

		animationCompletion = callback
		let animation = CAKeyframeAnimation()
		animation.keyPath = "contents"
		animation.values = getAnimationImages(percentage)
		animation.repeatCount = isDefinite ? 0.0 : Float.infinity
		animation.duration = animationDuration
		animation.delegate = self

		animationView.layer.add(animation, forKey: "contents")
		var index = getAnimationEndIndex(percentage)
		index = index > 0 ? index - 1 : index
		animationView.image = animationView.animationImages?[index]
		animationPercentage = percentage
	}

	func stopAnimating() {

		animationPercentage = 0.0
		percentage = 0.0
		animationView.isHidden = true
		animationView.stopAnimating()
		pullImageView.isHidden = false
		guard let scrollView = superview as? UIScrollView else {
			return
		}
		scrollView.bounces = self.scrollViewBounces
		UIView.animate(withDuration: animationDuration,
		               animations: {
						scrollView.contentInset = self.scrollViewInsets
						self.pullImageView.transform = CGAffineTransform.identity
		}, completion: { _ in
			self.state = .pulling
		})
	}
}

extension RefreshView: CAAnimationDelegate {

	func animationDidStop(_ anim: CAAnimation, finished flag: Bool) {

		animationCompletion?(animationPercentage)
	}
}

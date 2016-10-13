//
//  UIScrollView+Extension.swift
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

import Foundation
import UIKit

struct RefreshConst {

	static let pullTag = 810
}

public extension UIScrollView {

	open func addRefreshView( options: RefreshViewOptions,
	                          refreshCompletion :((Void) -> Void)?) {

		let refreshView = RefreshView(options: options,
		                              pullImage: options.pullImage,
		                              animationImages: getAnimationImages(options)!,
		                              refreshCompletion: refreshCompletion)
		refreshView.tag = RefreshConst.pullTag
		addSubview(refreshView)
	}

	public func startPullRefresh() {
		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.state = .refreshing
	}

	public func stopPullRefreshEver(_ ever:Bool = false) {
		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		if ever {
			refreshView?.state = .finish
		} else {
			refreshView?.state = .stop
		}
	}

	public func removePullRefresh() {
		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.removeFromSuperview()
	}

	private func getAnimationImages(_ options: RefreshViewOptions) -> [UIImage]? {

		var animationImages = options.animationImages
		if let gifImage = options.gifImage  {

			animationImages = UIImage.imagesFromGif(name: gifImage)
		}

		return animationImages == nil ? [UIImage]() : animationImages
	}

	private func refreshViewWithTag(_ tag:Int) -> RefreshView? {
		let pullToRefreshView = viewWithTag(tag)
		return pullToRefreshView as? RefreshView
	}
}

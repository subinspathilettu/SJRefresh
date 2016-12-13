//
//  UIScrollView+Extension.swift
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


import Foundation
import UIKit

struct RefreshConst {

	static let pullTag = 810
}

/**
*  Open UIScrollView extension for add/remove/start/stop refresh view.
*/
public extension UIScrollView {

	/**
	* Method for add refreshview to scrollview.
	*
	* - parameter refreshCompletion: Refresh start callback.
	*/
	public func addRefreshView(_ refreshCompletion: ((Void) -> Void)?) {

		let refreshView = RefreshView(refreshCompletion: refreshCompletion)
		refreshView.tag = RefreshConst.pullTag
		addSubview(refreshView)
		refreshView.addPullWave()
	}

	/**
	* Method for removing refresh view from scrollview.
	*/
	public func removePullRefresh() {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.removeFromSuperview()
	}

	/**
	* Method for stop refresh animation.
	*/
	public func stopRefreshAnimation() {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.ballView?.endAnimation() { _ in
			refreshView?.ballView?.isHidden = true
			let yPos = -((refreshView?.frame.height)! - (refreshView?.bendDistance)!)
			self.setContentOffset(CGPoint(x: 0, y: yPos), animated: false)
			self.setContentOffset(CGPoint.zero, animated: true)
			self.isScrollEnabled = true
		}
	}

	fileprivate func refreshViewWithTag(_ tag: Int) -> RefreshView? {

		let pullToRefreshView = viewWithTag(tag)
		return pullToRefreshView as? RefreshView
	}
}

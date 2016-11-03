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
	* - parameter theme: custom RefreshViewThemeProtocol.
	* - parameter refreshCompletion: Refresh start callback.
	*/
	public func addRefreshView<T: RefreshViewThemeProtocol>(theme theme: T,
	                           definite: Bool,
	                           refreshCompletion: ((Void) -> Void)?) {

		let refreshView = RefreshView(theme: theme,
		                              definite: definite,
		                              refreshCompletion: refreshCompletion)
		refreshView.tag = RefreshConst.pullTag
		addSubview(refreshView)
	}

	/**
	* Method for add refreshview to scrollview.
	*
	* - parameter options: custom RefreshViewOptions to customise refresh view.
	* - parameter refreshCompletion: Refresh start callback.
	*/
	public func addRefreshView(options: RefreshViewOptions,
	                          refreshCompletion: ((Void) -> Void)?) {

		let refreshView = RefreshView(options: options,
		                              refreshCompletion: refreshCompletion)
		refreshView.tag = RefreshConst.pullTag
		addSubview(refreshView)
	}

	/**
	* Method for add refreshview to scrollview.
	*
	* - parameter refreshCompletion: Refresh start callback.
	*/
	public func addRefreshView(definite: Bool,
	                           refreshCompletion: ((Void) -> Void)?) {

		let options = RefreshViewOptions()
		options.definite = definite
		let refreshView = RefreshView(options: options,
		                              refreshCompletion: refreshCompletion)
		refreshView.tag = RefreshConst.pullTag
		addSubview(refreshView)
	}

	/**
	* Method for start refreshview animations.
	*/
	public func startPullRefresh() {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.state = .refreshing
	}

	/**
	* Method for stop refreshview animations.
	*/
	public func stopPullRefresh() {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.state = .stop
	}

	/**
	* Method for set refresh percentage.
	*/
	public func setRefreshPrecentage(_ percentage: CGFloat) {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)

		if (refreshView?.options.definite)! {

			refreshView?.percentage = percentage
		} else {

			print("Invalid function call. \"setRefreshPrecentage\" "
				+ "is not required for definite refresh.")
		}
	}

	/**
	* Method for removing refresh view from scrollview.
	*/
	public func removePullRefresh() {

		let refreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		refreshView?.removeFromSuperview()
	}

	private func refreshViewWithTag(_ tag: Int) -> RefreshView? {
		let pullToRefreshView = viewWithTag(tag)
		return pullToRefreshView as? RefreshView
	}
}

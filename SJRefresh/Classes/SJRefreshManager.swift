//
//  SJRefreshManager.swift
//  Pods
//
//  Created by Subins on 16/12/16.
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

struct RefreshConst {
	static let pullTag = 810
	static let RefreshTriggered = "SJRefreshTriggered"
	static let StopRefreshAnimation = "SJStopRefreshAnimation"
}


public typealias RefreshTriggeredCallback = (Void) -> Void

public class SJRefresh {

	public var refreshTriggeredCallback: RefreshTriggeredCallback?
	public static let sharedInstance = SJRefresh()

	deinit {

		NotificationCenter.default.removeObserver(self,
		                                          name: Notification.Name(RefreshConst.RefreshTriggered),
		                                          object: nil)
	}

	let contentOffsetKeyPath = "contentOffset"
	var kvoContext = "PullToRefreshKVOContext"
	var sharedTheme: UIView?

	public func setTheme(_ theme: UIView) {

		self.sharedTheme = theme
	}

	func addRefreshViewTo(scrollView: UIScrollView, callback: RefreshTriggeredCallback? = nil) {

		refreshTriggeredCallback = callback
		if sharedTheme != nil {
			addTheme(sharedTheme!,
			         scrollView: scrollView)
		}
	}

	func addRefreshViewTo(scrollView: UIScrollView,
	                      theme: UIView,
	                      callback: RefreshTriggeredCallback? = nil) {

		refreshTriggeredCallback = callback
		addTheme(theme,
		         scrollView: scrollView)
	}

	func addTheme(_ theme: UIView, scrollView: UIScrollView) {

		NotificationCenter.default.addObserver(scrollView,
		                                       selector: #selector(scrollView.refreshTriggered(_:)),
		                                       name: Notification.Name(RefreshConst.RefreshTriggered),
		                                       object: nil)

		theme.tag = RefreshConst.pullTag
		scrollView.addSubview(theme)
		scrollView.addObserver(theme, forKeyPath: contentOffsetKeyPath,
		                       options: .initial,
		                       context: &kvoContext)
	}

	func removeRefresh(scrollView: UIScrollView) {

		scrollView.removeObserver(sharedTheme!, forKeyPath: contentOffsetKeyPath, context: &kvoContext)
		let refreshView = scrollView.viewWithTag(RefreshConst.pullTag)
		refreshView?.removeFromSuperview()
	}

	func stopRefreshAnimation(scrollView: UIScrollView) {

		NotificationCenter.default.post(name: Notification.Name(RefreshConst.StopRefreshAnimation),
		                                object: nil)
	}
}

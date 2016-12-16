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

/**
* UIScrollView extension
*/
public extension UIScrollView {

	public func addRefresh(_ callback: RefreshTriggeredCallback? = nil) {

		SJRefresh.sharedInstance.addRefreshViewTo(scrollView: self,
		                                          callback: callback)
	}

	public func addRefresh(theme: UIView, callback: RefreshTriggeredCallback? = nil) {

		SJRefresh.sharedInstance.addRefreshViewTo(scrollView: self,
		                                          theme: theme,
		                                          callback: callback)
	}

	public func removeRefresh() {

		SJRefresh.sharedInstance.removeRefresh(scrollView: self)
	}

	public func stopRefreshAnimation() {

		SJRefresh.sharedInstance.stopRefreshAnimation(scrollView: self)
	}

	func refreshTriggered(_ notification: Notification) {

		if let scrollView = notification.object as? UIScrollView, scrollView == self {
			SJRefresh.sharedInstance.refreshTriggeredCallback?()
		}
	}
}

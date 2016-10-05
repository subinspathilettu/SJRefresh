//
//  UIScrollView+Extension.swift
//  Pods
//
//  Created by Subins on 05/10/16.
//
//

import Foundation
import UIKit

public extension UIScrollView {

	fileprivate func refreshViewWithTag(_ tag:Int) -> RefreshView? {
		let pullToRefreshView = viewWithTag(tag)
		return pullToRefreshView as? RefreshView
	}

	open func addRefreshView(_ animationImages: [UIImage],
	                         refreshCompletion :((Void) -> Void)?) {

		addPullRefresh(animationImages,
		               refreshCompletion: refreshCompletion)
	}

	public func addPullRefresh(_ animationImages: [UIImage],
	                           refreshCompletion :(((Void) -> Void)?),
	                           options: RefreshOption = RefreshOption()) {
		let refreshViewFrame = CGRect(x: 0,
		                              y: -RefreshConst.height,
		                              width: self.frame.size.width,
		                              height: RefreshConst.height)
		let refreshView = RefreshView(options: options,
		                              animationImages: animationImages,
		                              frame: refreshViewFrame,
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

	public func startPushRefresh() {
		let refreshView = self.refreshViewWithTag(RefreshConst.pushTag)
		refreshView?.state = .refreshing
	}

	public func stopPushRefreshEver(_ ever:Bool = false) {
		let refreshView = self.refreshViewWithTag(RefreshConst.pushTag)
		if ever {
			refreshView?.state = .finish
		} else {
			refreshView?.state = .stop
		}
	}

	public func removePushRefresh() {
		let refreshView = self.refreshViewWithTag(RefreshConst.pushTag)
		refreshView?.removeFromSuperview()
	}

	// If you want to RefreshView fixed top potision, Please call this function in scrollViewDidScroll
	public func fixedPullToRefreshViewForDidScroll() {
		let pullToRefreshView = self.refreshViewWithTag(RefreshConst.pullTag)
		if !RefreshConst.fixedTop || pullToRefreshView == nil {
			return
		}
		var frame = pullToRefreshView!.frame
		if self.contentOffset.y < -RefreshConst.height {
			frame.origin.y = self.contentOffset.y
			pullToRefreshView!.frame = frame
		}
		else {
			frame.origin.y = -RefreshConst.height
			pullToRefreshView!.frame = frame
		}
	}
}

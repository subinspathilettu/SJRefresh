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

	open func addRefreshView( options: RefreshViewOptions,
	                          refreshCompletion :((Void) -> Void)?) {

		addPullRefresh(pullImage: options.pullImage!,
		               animationImages: getAnimationImages(options)!,
		               refreshCompletion: refreshCompletion)
	}

	public func addPullRefresh(pullImage: String?,
	                           animationImages: [UIImage],
	                           refreshCompletion :(((Void) -> Void)?),
	                           options: RefreshViewOptions = RefreshViewOptions()) {

		let refreshView = RefreshView(options: options,
		                              pullImage: pullImage,
		                              animationImages: animationImages,
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

	fileprivate func getAnimationImages(_ options: RefreshViewOptions) -> [UIImage]? {

		var animationImages = options.animationImages
		if let gifImage = options.gifImage  {

			animationImages = UIImage.imagesFromGif(name: gifImage)
		}

		return animationImages
	}

	fileprivate func refreshViewWithTag(_ tag:Int) -> RefreshView? {
		let pullToRefreshView = viewWithTag(tag)
		return pullToRefreshView as? RefreshView
	}
}

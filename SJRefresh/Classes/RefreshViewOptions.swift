//
//  RefreshViewOptions.swift
//  Pods
//
//  Created by Subins on 05/10/16.
//
//

import UIKit

//public struct RefreshOption {
//
//	public var pullImage: String?
//	public var gifimage: String?
//	public var animationImages: [UIImage]?
//	public var backgroundColor = UIColor.clear
//	public var indicatorColor = UIColor.gray
//	public var autoStopTime: Double = 0 // 0 is not auto stop
//	public var fixedSectionHeader = false  // Update the content inset for fixed section headers
//}

open class RefreshViewOptions: NSObject {

	open var pullImage: String?
	open var gifImage: String?
	open var animationImages: [UIImage]?
	open var backgroundColor = UIColor.clear
	open var indicatorColor = UIColor.gray
	open var viewHeight: CGFloat = 80.0
}

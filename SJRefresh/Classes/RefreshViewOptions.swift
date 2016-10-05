//
//  RefreshViewOptions.swift
//  Pods
//
//  Created by Subins on 05/10/16.
//
//

import UIKit

public struct RefreshOption {

	public var backgroundColor = UIColor.clear
	public var indicatorColor = UIColor.gray
	public var autoStopTime: Double = 0 // 0 is not auto stop
	public var fixedSectionHeader = false  // Update the content inset for fixed section headers
}

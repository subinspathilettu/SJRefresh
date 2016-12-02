//
//  SJTheme.swift
//  Pods
//
//  Created by Subins on 16/11/16.
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

public class SJTheme {

	public init() {
	}
}

extension SJTheme: SJRefreshThemeProtocol {

	public func heightForRefreshView() -> CGFloat {
		return 120.0
	}

	public func pullImageForRefreshView() -> UIImage {
		return UIImage(named: "Arrow", in: Bundle(for: type(of: self)), compatibleWith: nil)!
	}

	public func pullImageForRefreshView(state: SJRefreshState,
	                             pullPercentage percentage: CGFloat) -> UIImage? {

		if state == .pulling {

			return UIImage(named: "Arrow", in: Bundle(for: type(of: self)), compatibleWith: nil)!
		} else if state == .triggered {
			return UIImage(named: "Arrow-rotated",
			               in: Bundle(for: type(of: self)), compatibleWith: nil)!
		} else {
			return UIImage()
		}
	}

	public func imagesForRefreshViewLoadingAnimation() -> [UIImage] {

		let bundle = Bundle(for: type(of: self))
		guard let bundleURL = bundle.url(forResource: "loader_gear",
		                                 withExtension: "gif") else {
											print("This image does not exist")
											return [UIImage]()
		}

		return UIImage.imagesFromGifURL(bundleURL)!
	}

	public func backgroundColorForRefreshView() -> UIColor {

		return UIColor.clear
	}

	public func backgroundImageForRefreshView() -> UIImage? {
		
		return nil
	}
}

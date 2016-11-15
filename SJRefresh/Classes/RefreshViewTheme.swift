//
//  RefreshViewTheme.swift
//  Pods
//
//  Created by Subins on 15/11/16.
//
//

import Foundation
import RefreshThemeProtocol

class RefreshViewTheme {
}

extension RefreshViewTheme: RefreshViewThemeProtocol {

	func heightForRefreshView() -> CGFloat {

		return 100.0
	}

	func pullImageForRefreshView() -> UIImage {

		return UIImage(named: "Arrow", in: Bundle(for: type(of: self)), compatibleWith: nil)!
	}

	func gifForRefreshViewLoadingAnimation() -> String {

		return "loader_gear"
	}
}


//
//  AppDelegate.swift
//  SJRefresh
//
//  Created by Subins Jose on 10/04/2016.
//  Copyright (c) 2016 Subins Jose. All rights reserved.
//

import UIKit
import SJRefresh

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions
		launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

		SJRefresh.shared.setTheme(SJTheme())
		return true
    }
}

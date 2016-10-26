//
//  ViewController.swift
//  SJRefresh
//
//  Created by Subins Jose on 10/04/2016.
//  Copyright (c) 2016 Subins Jose. All rights reserved.
//

import UIKit
import SJRefresh

class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!

	override func viewDidLoad() {
		super.viewDidLoad()

		let options = RefreshViewOptions()
		options.pullImage = "pulltorefresharrow"
		options.gifImage = "Loader"
		options.definite = true

		tableView.addRefreshView(options: options) { _ in

			if options.definite == true {

				//definite animation
				self.tableView.setRefreshPrecentage(60)
				self.perform(#selector(self.animate(_:)),
				             with: 80.0,
				             afterDelay: 2.0)
				self.perform(#selector(self.animate(_:)),
				             with: 100.0,
				             afterDelay: 3.0)
			} else {

				// Indefinite animation
				sleep(2)
				self.tableView.stopPullRefresh()
			}
		}
	}

	func animate(_ percentage: NSNumber) {

		tableView.setRefreshPrecentage(CGFloat(percentage.floatValue))
	}
}

extension ViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		return 20
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
		cell?.textLabel?.text = String(indexPath.row)
		return cell!
	}
}

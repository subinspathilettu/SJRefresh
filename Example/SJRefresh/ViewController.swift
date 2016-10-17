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

		tableView.addRefreshView(options: options) { _ in
			sleep(3)
			self.tableView.stopPullRefreshEver()
		}
	}

	func stopRefresh() {
		tableView.stopPullRefreshEver()
	}
}

extension ViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

		//Temp count
		return 20
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		//Temp cell
		let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
		cell?.textLabel?.text = String(indexPath.row)
		return cell!
	}
}

extension ViewController: UITableViewDelegate {

	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

		tableView.startPullRefresh()
		perform(#selector(stopRefresh), with: nil, afterDelay: 2.0)
	}
}

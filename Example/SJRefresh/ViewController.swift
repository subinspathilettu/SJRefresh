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

		tableView.addRefreshView({ (_) in
			self.perform(#selector(self.stop), with: nil, afterDelay: 3.0)
		})
	}

	func stop() {
		tableView.stopRefreshAnimation()
	}
}

extension ViewController: UITableViewDataSource {

	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return 10
	}

	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")
		return cell!
	}
}

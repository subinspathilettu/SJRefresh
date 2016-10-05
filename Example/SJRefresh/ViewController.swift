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

		tableView.addRefreshView([UIImage(named: "pulltorefresharrow.png")!,
		                          UIImage(named: "pulltorefresharrowUp.png")!]) { _ in

			self.tableView.stopPullRefreshEver()
		}
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


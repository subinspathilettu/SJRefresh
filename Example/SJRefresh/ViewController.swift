//
//  ViewController.swift
//  SJRefresh
//
//  Created by Subins Jose on 10/04/2016.
//  Copyright (c) 2016 Subins Jose. All rights reserved.
//

import UIKit
import SJRefresh
import Alamofire
import AlamofireImage

class ViewController: UIViewController {

	@IBOutlet weak var tableView: UITableView!
	var items = [AnyObject]()

	override func viewDidLoad() {
		super.viewDidLoad()

		let options = RefreshViewOptions()
		options.gifImage = "Loader"

		tableView.addRefreshView(options: options) { _ in
			Alamofire.request("https://www.googleapis.com/books/v1/volumes?q=crime")
				.responseJSON { response in
				if let JSON = response.result.value as? [String : AnyObject] {
					self.items = JSON["items"] as! [AnyObject]
				}

				self.tableView.reloadData()
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

		return items.count
	}

	func tableView(_ tableView: UITableView, cellForRowAt
		indexPath: IndexPath) -> UITableViewCell {

		let cell = tableView.dequeueReusableCell(withIdentifier: "CellIdentifier")

		let item = items[indexPath.row] as? [String : AnyObject]
		let volumInfo = item?["volumeInfo"] as? [String : AnyObject]
		let imageLinks = volumInfo?["imageLinks"] as? [String : String]
		let thumbNailImage = imageLinks?["thumbnail"]

		cell?.textLabel?.text = volumInfo?["title"] as? String
		cell?.detailTextLabel?.text = volumInfo?["description"] as? String
		cell?.imageView?.af_setImage(withURL: URL.init(string: thumbNailImage!)!,
		                             placeholderImage: nil,
		                             completion: { (image) in
		})

		return cell!
	}
}

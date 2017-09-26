//
//  StudentsListController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import UIKit

class StudentsListController: UIViewController, UITableViewDataSource, UITableViewDelegate {
	
	//MARK: Constants
	
	let cellIdentifier = "StudentRecordCell"
	
	//MARK: Outlets
	
	@IBOutlet var studentTableView: UITableView!
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(tabBarController! as! StudentsTabBarController).updateTableView = displayStudentRecords
	}
	
	func displayStudentRecords() {
		print("Displaying student records in list.")
		studentTableView.reloadData()
	}
	
	//MARK: UITableViewDataSource implementation
	
	func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
		return ParseClient.shared.studentRecords.count
	}
	
	func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
		let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath)
		
		guard let record = ParseClient.shared.getRecordInCache(fromIndex: indexPath.row) else {
			print ("Record was not found.")
			return cell
		}
		
		cell.textLabel?.text = "\(record.firstName) \(record.lastName)"
		
		return cell
	}
	
	//MARK: UITableViewDelegate implementation
	
	//navigate to student's media URL on row tap
	func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
		guard let record = ParseClient.shared.getRecordInCache(fromIndex: indexPath.row) else {
			print ("Record was not found.")
			return
		}
		
		Utilities.openURL(record.mediaURL)
	}
}

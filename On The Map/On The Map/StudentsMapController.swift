//
//  StudentsMapController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/21.
//

import UIKit

class StudentsMapController: UIViewController {
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(tabBarController! as! StudentsTabBarController).completionForGettingStudentRecords = displayStudentRecords
	}
	
	func displayStudentRecords() {
		print("Displaying student records on map.")
	}
}

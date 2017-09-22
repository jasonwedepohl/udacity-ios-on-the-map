//
//  StudentsTabBarController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/19.
//
//

import UIKit

class StudentsTabBarController: UITabBarController {
	
	//MARK: Properties
	
	var completionForGettingStudentRecords: (() -> ())?
	let waitingSpinner = WaitingSpinner()
	
	//MARK: Outlets
	
	@IBOutlet var refreshButton: UIBarButtonItem!
	
	//MARK: Actions
	
	@IBAction func logout(_ sender: Any) {
		waitingSpinner.show(self)
		
		UdacityClient.shared.logout(completion: {(successful, displayError) in
			DispatchQueue.main.async {
				self.waitingSpinner.hide()
				if (successful) {
					self.dismiss(animated: true, completion: nil)
				} else {
					Utilities.showErrorAlert(self, displayError)
				}
			}
		})
	}
	
	@IBAction func refresh() {
		//do not allow the user to refresh during load
		refreshButton.isEnabled = false
		waitingSpinner.show(self)
		
		ParseClient.shared.getStudentLocations { (successful, error, studentRecords) in
			DispatchQueue.main.async {
				self.refreshButton.isEnabled = true
				self.waitingSpinner.hide()
				
				if successful {
					StudentRecordCache.instance.set(studentRecords!)
					
					if self.completionForGettingStudentRecords == nil {
						print("Completion handler for student records is not set!")
						return
					}
					self.completionForGettingStudentRecords?()
				} else {
					Utilities.showErrorAlert(self, error)
				}
			}
		}
	}
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		if (StudentRecordCache.instance.getAll().isEmpty) {
			refresh()
		}
	}
}

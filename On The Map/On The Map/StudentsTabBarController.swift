//
//  StudentsTabBarController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/19.
//
//

import UIKit

class StudentsTabBarController: UITabBarController {
	
	//MARK: Constants
	
	let informationPostingSegue = "InformationPostingSegue"
	let overwriteAlertQuestion = "You have already posted a location. Would you like to overwrite it?"
	
	//MARK: Properties
	
	var updateMapView: (() -> ())?
	var updateTableView: (() -> ())?
	let waitingSpinner = WaitingSpinner()
	
	//MARK: Outlets
	
	@IBOutlet var refreshButton: UIBarButtonItem!
	@IBOutlet var addPinButton: UIBarButtonItem!
	
	//MARK: Actions
	
	@IBAction func logout(_ sender: Any) {
		ParseClient.shared.needsRefresh = true
		
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
	
	@IBAction func addPin(_ sender: Any) {
		if ParseClient.shared.loggedInStudentRecordID == nil {
			waitingSpinner.show(self)
			
			ParseClient.shared.getLoggedInStudentRecord() { (successful, displayError) in
				DispatchQueue.main.async {
					self.waitingSpinner.hide()
					
					if (successful) {
						if ParseClient.shared.loggedInStudentRecordID == nil {
							self.segueToInformationPostingView()
						} else {
							self.showOverwriteAlert()
						}
					} else {
						Utilities.showErrorAlert(self, displayError)
					}
				}
			}
		} else {
			showOverwriteAlert()
		}
	}
	
	@IBAction func refresh() {
		//do not allow the user to refresh during load
		refreshButton.isEnabled = false
		waitingSpinner.show(self)
		
		ParseClient.shared.getStudentRecords { (successful, error) in
			DispatchQueue.main.async {
				self.refreshButton.isEnabled = true
				self.waitingSpinner.hide()
				
				if successful {
					if self.updateMapView == nil {
						print("Completion handler for updating map view is not set!")
					} else {
						self.updateMapView?()
					}
					
					if self.updateTableView == nil {
						print("Completion handler for updating table view is not set!")
					} else {
						self.updateTableView?()
					}
				} else {
					Utilities.showErrorAlert(self, error)
				}
			}
		}
	}
	
	private func showOverwriteAlert() {
		let alertController = UIAlertController(title: "Warning", message: overwriteAlertQuestion, preferredStyle: .alert)
		
		let okAction = UIAlertAction(title: "Overwrite", style: .default) { action in
			self.segueToInformationPostingView()
		}
		let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
		
		alertController.addAction(okAction)
		alertController.addAction(cancelAction)
		
		self.present(alertController, animated: true, completion: nil)
	}
	
	private func segueToInformationPostingView() {
		self.performSegue(withIdentifier: self.informationPostingSegue, sender: nil)
	}
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		if (ParseClient.shared.needsRefresh) {
			refresh()
		}
	}
}

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
	
	let logoutFailedMessage = "We couldn't log you out."
	
	//MARK: Actions
	
	@IBAction func logout(_ sender: Any) {
		UdacityClient.shared.logout(completion: {(successful) in
			DispatchQueue.main.async {
				if (successful) {
					self.dismiss(animated: true, completion: nil)
				} else {
					Utilities.showErrorAlert(self, self.logoutFailedMessage)
				}
			}
		})
	}
}

//
//  StudentsTabBarController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/19.
//
//

import UIKit

class StudentsTabBarController: UITabBarController {
	
	@IBAction func logout(_ sender: Any) {
		UdacityClient.shared.logout(completion: {(successful, displayError) in
			DispatchQueue.main.async {
				if (successful) {
					self.dismiss(animated: true, completion: nil)
				} else {
					Utilities.showErrorAlert(self, displayError)
				}
			}
		})
	}
}

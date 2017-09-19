//
//  ViewController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/18.
//

import UIKit
import FacebookCore
import FacebookLogin

class LoginViewController: UIViewController {
	
	//MARK: Constants
	
	let loginSegue = "LoginSegue"
	let loginFailedMessage = "We couldn't log you in."
	let udacitySignUpUrl = "https://www.udacity.com/account/auth#!/signup"
	
	//MARK: Outlets
	
	@IBOutlet var emailField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var signUpLabel: UILabel!
	@IBOutlet var loginWithFacebookButton: UIButton!
	
	//MARK: Actions
	
	@IBAction func login(_ sender: Any) {
		if emailField.text!.isEmpty || passwordField.text!.isEmpty {
			return
		}
		
		UdacityClient.shared.login(email: emailField.text!, password: passwordField.text!, completion: completeLogin(_:))
	}
	
	//MARK: UIViewController overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
		
		//bind "sign up" label tap to redirect user to Udacity signup page
		let signUpTap = UITapGestureRecognizer(target: self, action: #selector(redirectToUdacitySignUp))
		signUpLabel.isUserInteractionEnabled = true
		signUpLabel.addGestureRecognizer(signUpTap)
		
		//bind facebook login button
		loginWithFacebookButton.addTarget(self, action: #selector(loginWithFacebook), for: .touchUpInside)
    }
	
	@objc private func redirectToUdacitySignUp() {
		Utilities.openURL(udacitySignUpUrl)
	}
	
	@objc private func loginWithFacebook() {
		let loginManager = LoginManager()
		loginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
			
			switch loginResult {
				
			case .failed(let error):
				print(error)
			
			case .cancelled:
				print("User cancelled Facebook login.")
			
			case .success:
				print("Facebook login was successful.")
				UdacityClient.shared.loginWithFacebook(completion: self.completeLogin(_:))
				
			}
		}
	}
	
	private func completeLogin(_ successful: Bool) {
		DispatchQueue.main.async {
			if (successful) {
				self.performSegue(withIdentifier: self.loginSegue, sender: nil)
			} else {
				Utilities.showErrorAlert(self, self.loginFailedMessage)
			}
		}
	}
}


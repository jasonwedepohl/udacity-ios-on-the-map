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
	let udacitySignUpUrl = "https://www.udacity.com/account/auth#!/signup"
	
	//MARK: Properties
	
	var blurView: UIVisualEffectView? = nil
	var spinnerView: UIActivityIndicatorView? = nil
	
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
		
		showWaitingSpinner()
		
		UdacityClient.shared.login(email: emailField.text!, password: passwordField.text!, completion: completeLogin(_:_:))
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
				
				self.showWaitingSpinner()
				
				UdacityClient.shared.loginWithFacebook(completion: self.completeLogin(_:_:))
				
			}
		}
	}
	
	private func completeLogin(_ successful: Bool, _ displayError: String?) {
		DispatchQueue.main.async {
			if (successful) {
				self.performSegue(withIdentifier: self.loginSegue, sender: nil)
			} else {
				Utilities.showErrorAlert(self, displayError)
			}
			
			self.hideWaitingSpinner()
		}
	}
	
	private func showWaitingSpinner() {
		//first add blur view to blur screen contents
		blurView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
		blurView!.frame = view.bounds
		view.addSubview(blurView!)
		
		//then add a spinner in the center
		spinnerView = UIActivityIndicatorView(activityIndicatorStyle: .whiteLarge)
		spinnerView?.center = view.center
		spinnerView?.startAnimating()
		view.addSubview(spinnerView!)
	}
	
	private func hideWaitingSpinner() {
		if (blurView != nil) {
			blurView!.removeFromSuperview()
			blurView = nil
		}
		
		if (spinnerView != nil) {
			spinnerView!.removeFromSuperview()
			spinnerView = nil
		}
	}
}


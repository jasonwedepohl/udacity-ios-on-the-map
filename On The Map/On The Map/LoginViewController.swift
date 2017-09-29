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
	
	let waitingSpinner = WaitingSpinner()
	let facebookLoginManager = LoginManager()
	var activeField: UITextField?
	
	//MARK: Outlets
	
	@IBOutlet var emailField: UITextField!
	@IBOutlet var passwordField: UITextField!
	@IBOutlet var signUpLabel: UILabel!
	@IBOutlet var loginWithFacebookButton: UIButton!
	@IBOutlet var scrollView: UIScrollView!
	
	//MARK: Actions
	
	@IBAction func login(_ sender: Any) {
		if emailField.text!.isEmpty || passwordField.text!.isEmpty {
			return
		}
		
		waitingSpinner.show(self)
		
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
		
		emailField.delegate = self
		passwordField.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
	
	@objc private func redirectToUdacitySignUp() {
		Utilities.openURL(udacitySignUpUrl)
	}
	
	@objc private func loginWithFacebook() {
		waitingSpinner.show(self)
		
		facebookLoginManager.logIn([ .publicProfile ], viewController: self) { loginResult in
			
			switch loginResult {
				
			case .failed(let error):
				print("Error while trying to log in to Facebook: \(error)")
				DispatchQueue.main.async {
					self.waitingSpinner.hide()
				}
			
			case .cancelled:
				print("User cancelled Facebook login.")
				DispatchQueue.main.async {
					self.waitingSpinner.hide()
				}
			
			case .success:
				print("Facebook login was successful.")
				
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
			
			self.waitingSpinner.hide()
		}
	}
}

//MARK: TextField/Keyboard scroll handling extension
/*
	References:
	1. https://stackoverflow.com/a/28813720
	2. https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

extension LoginViewController : UITextFieldDelegate {
	func subscribeToKeyboardNotifications() {
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(_:)), name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(_:)), name: .UIKeyboardWillHide, object: nil)
	}
	
	func unsubscribeFromKeyboardNotifications() {
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillShow, object: nil)
		NotificationCenter.default.removeObserver(self, name: .UIKeyboardWillHide, object: nil)
	}
	
	func keyboardWillShow(_ notification: Notification) {
		scrollView.isScrollEnabled = true
		let keyboardHeight = getKeyboardHeight(notification)
		let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardHeight, 0.0)
		
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets
		
		var aRect : CGRect = view.frame
		aRect.size.height -= keyboardHeight
		if let activeField = self.activeField {
			if (!aRect.contains(activeField.frame.origin)) {
				scrollView.scrollRectToVisible(activeField.frame, animated: true)
			}
		}
	}
	
	func keyboardWillHide(_ notification: Notification) {
		let keyboardHeight = getKeyboardHeight(notification)
		let contentInsets : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, -keyboardHeight, 0.0)
		scrollView.contentInset = contentInsets
		scrollView.scrollIndicatorInsets = contentInsets
		scrollView.isScrollEnabled = false
	}
	
	func getKeyboardHeight(_ notification: Notification) -> CGFloat {
		let userInfo = notification.userInfo
		let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
		return keyboardSize.cgRectValue.height
	}
	
	func textFieldDidBeginEditing(_ textField: UITextField) {
		activeField = textField
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		activeField = nil
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		return true
	}
}


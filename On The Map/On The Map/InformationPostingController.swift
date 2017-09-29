//
//  InformationPostingController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import UIKit
import MapKit

class InformationPostingController: UIViewController {
	
	//MARK: Constants
	
	let pinReuseID = "Pin"
	let mapStringInputTag = 400
	let mediaUrlInputTag = 401
	
	//MARK: Properties
	
	let waitingSpinner = WaitingSpinner()
	var mapString = ""
	var coordinate: CLLocationCoordinate2D? = nil
	var activeField: UITextField?

	//MARK: Outlets
	
	@IBOutlet var mapStringPrompt: UILabel!
	@IBOutlet var mapStringInput: UITextField!
	@IBOutlet var mediaURLPrompt: UILabel!
	@IBOutlet var mediaURLInput: UITextField!
	@IBOutlet var mapView: MKMapView!
	@IBOutlet var scrollView: UIScrollView!
	
	//MARK: Actions
	
	@IBAction func cancel() {
		dismiss(animated: true, completion: nil)
	}
	
	//called when user hits "return" after entering a location
	func findLocation() {
		mapString = mapStringInput.text!
		
		waitingSpinner.show(self)
		
		LocationFinder.find(mapString) { (coordinate) in
			DispatchQueue.main.async {
				self.waitingSpinner.hide()
				
				if coordinate == nil {
					Utilities.showErrorAlert(self, "Could not find the location of \"\(self.mapString)\".")
				} else {
					self.coordinate = coordinate
					self.showLocationAndAllowSubmit()
				}
			}
		}
	}
	
	//called when user hits "return" after entering a media URL
	func submit() {
		let mediaURL = mediaURLInput.text!
		if mediaURL.isEmpty {
			Utilities.showErrorAlert(self, "Please enter a URL.")
			return
		}
		
		waitingSpinner.show(self)
		
		ParseClient.shared.setStudentRecord(mapString,
		                                    coordinate!.latitude,
		                                    coordinate!.longitude,
		                                    mediaURL) { (successful, displayError) in
			DispatchQueue.main.async {
				self.waitingSpinner.hide()
				
				if (successful) {
					self.dismiss(animated: true, completion: nil)
				} else {
					Utilities.showErrorAlert(self, displayError)
				}
			}
		}
	}
	
	private func showLocationAndAllowSubmit() {
		mapStringPrompt.isHidden = true
		mapStringInput.isHidden = true
		
		mapView.isHidden = false
		mediaURLPrompt.isHidden = false
		mediaURLInput.isHidden = false
		
		//navigate to map location
		mapView.setCenter(coordinate!, animated: false)
		
		//add pin
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate!
		mapView.addAnnotation(annotation)
	}
	
	//MARK: UIViewController overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
		mediaURLPrompt.isHidden = true
		mediaURLInput.isHidden = true
		mapView.isHidden = true
		
		mapStringInput.tag = mapStringInputTag
		mediaURLInput.tag = mediaUrlInputTag
		
		mapStringInput.delegate = self
		mediaURLInput.delegate = self
    }
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		subscribeToKeyboardNotifications()
	}
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear(animated)
		unsubscribeFromKeyboardNotifications()
	}
}

//MARK: MKMapViewDelegate extension

extension InformationPostingController: MKMapViewDelegate {
	// Create annotation view
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseID) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
			pinView!.pinTintColor = .red
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
}

//MARK: UITextViewDelegate extension

extension InformationPostingController: UITextFieldDelegate {
	func textFieldDidBeginEditing(_ textField: UITextField) {
		activeField = textField
	}
	
	func textFieldDidEndEditing(_ textField: UITextField) {
		activeField = nil
	}
	
	func textFieldShouldReturn(_ textField: UITextField) -> Bool {
		textField.resignFirstResponder()
		if textField.tag == mapStringInputTag {
			findLocation()
		} else if textField.tag == mediaUrlInputTag {
			submit()
		}
		return true
	}
}

//MARK: TextField/Keyboard scroll handling extension
/*
References:
1. https://stackoverflow.com/a/28813720
2. https://developer.apple.com/library/content/documentation/StringsTextFonts/Conceptual/TextAndWebiPhoneOS/KeyboardManagement/KeyboardManagement.html
*/

extension InformationPostingController {
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
}

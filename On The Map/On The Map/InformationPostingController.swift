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

	//MARK: Outlets
	
	@IBOutlet var mapStringPrompt: UILabel!
	@IBOutlet var mapStringInput: UITextField!
	@IBOutlet var mediaURLPrompt: UILabel!
	@IBOutlet var mediaURLInput: UITextField!
	@IBOutlet var mapView: MKMapView!
	
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
		self.mapStringPrompt.isHidden = true
		self.mapStringInput.isHidden = true
		
		self.mapView.isHidden = false
		self.mediaURLPrompt.isHidden = false
		self.mediaURLInput.isHidden = false
		
		//navigate to map location
		self.mapView.setCenter(coordinate!, animated: false)
		
		//add pin
		let annotation = MKPointAnnotation()
		annotation.coordinate = coordinate!
		self.mapView.addAnnotation(annotation)
	}
	
	//MARK: UIViewController overrides
	
    override func viewDidLoad() {
        super.viewDidLoad()
		mediaURLPrompt.isHidden = true
		mediaURLInput.isHidden = true
		mapView.isHidden = true
		
		mapStringInput.tag = mapStringInputTag
		mediaURLInput.tag = mediaUrlInputTag
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

extension InformationPostingController: UITextViewDelegate {
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

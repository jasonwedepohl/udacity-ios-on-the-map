//
//  StudentsMapController.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/21.
//

import UIKit
import MapKit

class StudentsMapController: UIViewController, MKMapViewDelegate {
	
	//MARK: Constants
	
	let pinReuseID = "Pin"
	
	//MARK: Outlets
	
	@IBOutlet weak var mapView: MKMapView!
	
	//MARK: UIViewController overrides
	
	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear(animated)
		(tabBarController! as! StudentsTabBarController).updateMapView = displayStudentRecords
	}
	
	func displayStudentRecords() {
		print("Displaying student records on map.")
		
		//remove old annotations from the map
		let oldAnnotations = mapView.annotations
		mapView.removeAnnotations(oldAnnotations)
		
		//create new annotations
		var annotations = [MKPointAnnotation]()
		
		for record in ParseClient.shared.studentRecords {
			let lat = CLLocationDegrees(record.latitude)
			let long = CLLocationDegrees(record.longitude)
			
			let annotation = MKPointAnnotation()
			annotation.coordinate = CLLocationCoordinate2D(latitude: lat, longitude: long)
			annotation.title = "\(record.firstName) \(record.lastName)"
			annotation.subtitle = record.mediaURL
			
			annotations.append(annotation)
		}
		
		//add annotations to map
		mapView.addAnnotations(annotations)
	}
	
	//MARK: MKMapViewDelegate implementation
	
	// Create annotation view
	func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
		var pinView = mapView.dequeueReusableAnnotationView(withIdentifier: pinReuseID) as? MKPinAnnotationView
		
		if pinView == nil {
			pinView = MKPinAnnotationView(annotation: annotation, reuseIdentifier: pinReuseID)
			pinView!.canShowCallout = true
			pinView!.pinTintColor = .red
			pinView!.rightCalloutAccessoryView = UIButton(type: .detailDisclosure)
		}
		else {
			pinView!.annotation = annotation
		}
		
		return pinView
	}
	
	//Open browser to annotation link when user taps annotation
	func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
		if control == view.rightCalloutAccessoryView {
			if let mediaUrl = view.annotation?.subtitle! {
				Utilities.openURL(mediaUrl)
			}
		}
	}
}

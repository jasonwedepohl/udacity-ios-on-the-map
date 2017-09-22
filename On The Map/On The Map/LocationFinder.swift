//
//  LocationFinder.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import CoreLocation

class LocationFinder {
	static func find(_ searchString: String, _ findCompletion: @escaping (_ coordinate: CLLocationCoordinate2D?) -> Void) {
		CLGeocoder().geocodeAddressString(searchString, completionHandler: { (placemarks, error) in
			if error != nil {
				print(error!.localizedDescription)
				findCompletion(nil)
				return
			}
			
			if placemarks == nil || placemarks!.count == 0 {
				findCompletion(nil)
				return
			}
			
			guard let coordinate = placemarks![0].location?.coordinate else {
				findCompletion(nil)
				return
			}
			
			print("Coordinate: \(coordinate.latitude), \(coordinate.longitude)")
			findCompletion(coordinate)
		})
	}
}

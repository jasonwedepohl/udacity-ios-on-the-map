//
//  Utilities.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/19.
//
//

import Foundation
import UIKit

class Utilities {
	static func getValidResponseData(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> Data? {
		if error != nil {
			print("\(error!)")
			return nil
		}
		
		guard let httpResponse = response as? HTTPURLResponse else {
			print("Expected HTTPURLResponse but was \(type(of: response))")
			return nil
		}
		
		guard httpResponse.statusCode >= 200 && httpResponse.statusCode <= 299 else {
			print(NSString(data: data!, encoding: String.Encoding.utf8.rawValue)!)
			print("There was a problem with the request. Status code is \(httpResponse.statusCode)")
			return nil
		}
		
		guard let data = data else {
			print("No data was returned.")
			return nil
		}
		
		return data
	}
	
	static func getJson(_ data: Data) -> AnyObject?  {
		var parsedResult: AnyObject! = nil
		do {
			parsedResult = try JSONSerialization.jsonObject(with: data, options: .allowFragments) as AnyObject
		} catch {
			print("Could not parse the data as JSON: '\(data)'")
		}
		return parsedResult
	}
	
	static func showErrorAlert(_ controller: UIViewController, _ message: String) {
		let alert = UIAlertController(title: "Error", message: message, preferredStyle: UIAlertControllerStyle.alert)
		alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
		controller.present(alert, animated: true, completion: nil)
	}
	
	static func openURL(_ urlString: String) {
		let url = URL(string: urlString)!
		if #available(iOS 10.0, *) {
			UIApplication.shared.open(url, options: [:], completionHandler: nil)
		} else {
			UIApplication.shared.openURL(url)
		}
	}
}

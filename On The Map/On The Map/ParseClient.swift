//
//  ParseClient.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/21.
//

import Foundation

class ParseClient {
	//MARK: Singleton
	
	static let shared = ParseClient()
	
	//MARK: Constants
	
	let limit = 100
	
	struct Url {
		static let studentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
	}
	
	struct QueryKeys {
		static let limit = "limit"
		static let skip = "skip"
		static let order = "order"
	}
	
	struct RequestKeys {
		static let applicationID = "X-Parse-Application-Id"
		static let apiKey = "X-Parse-REST-API-Key"
	}
	
	struct RequestValues {
		static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	//MARK: Properties
	
	let session = URLSession.shared
	var waitingForLocations = false
	
	//MARK: Functions
	
	func getStudentLocations(completion: @escaping (_ success: Bool, _ displayError: String?, _ studentRecords: [StudentRecord]?) -> Void) {
		if waitingForLocations {
			return
		}
		waitingForLocations = true
		
		let request = NSMutableURLRequest(url: URL(string: Url.studentLocation + "?limit=100&order=-updatedAt")!)
		request.addValue(RequestValues.applicationID, forHTTPHeaderField: RequestKeys.applicationID)
		request.addValue(RequestValues.apiKey, forHTTPHeaderField: RequestKeys.apiKey)
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			
			self.waitingForLocations = false
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError, nil)
				return
			}
			
			guard let response:StudentRecordsResponse = JSONParser.decode(data!) else {
				completion(false, DisplayError.unexpected, nil)
				return
			}
			
			completion(true, nil, response.studentRecords)
		}
		task.resume()
	}
}

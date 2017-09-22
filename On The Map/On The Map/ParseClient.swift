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
	var studentRecords = [StudentRecord]()
	
	//MARK: Functions
	
	func getRecord(fromIndex index: Int) -> StudentRecord? {
		if (index >= studentRecords.count) {
			print("Student record index out of bounds.")
			return nil
		}
		return studentRecords[index]
	}
	
	func getStudentLocations(completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
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
				completion(false, responseError)
				return
			}
			
			guard let response:StudentRecordsResponse = JSONParser.decode(data!) else {
				completion(false, DisplayError.unexpected)
				return
			}
			
			//some of the Parse server's records have missing properties, so filter them out
			let validResponseResults = response.results.filter {
				$0.createdAt != nil &&
					$0.firstName != nil && !$0.firstName!.isEmpty &&
					$0.lastName != nil && !$0.lastName!.isEmpty &&
					$0.latitude != nil &&
					$0.longitude != nil &&
					$0.mapString != nil &&
					$0.mediaURL != nil && !$0.mediaURL!.isEmpty &&
					$0.objectId != nil &&
					$0.uniqueKey != nil &&
					$0.updatedAt != nil
			}
			
			self.studentRecords = validResponseResults.map { StudentRecord($0) }
			
			completion(true, nil)
		}
		task.resume()
	}
	
	//MARK: Response structs
	
	private struct StudentRecordsResponse : Codable {
		var results: [StudentRecordResponse]
	}
	
	struct StudentRecordResponse: Codable {
		var createdAt: String?
		var firstName: String?
		var lastName: String?
		var latitude: Float?
		var longitude: Float?
		var mapString: String?
		var mediaURL: String?
		var objectId: String?
		var uniqueKey: String?
		var updatedAt: String?
	}
}

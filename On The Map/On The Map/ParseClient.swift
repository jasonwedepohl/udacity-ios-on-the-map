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
	
	private struct Url {
		static let studentLocation = "https://parse.udacity.com/parse/classes/StudentLocation"
	}
	
	private let getLast100Query = "limit=100&order=-updatedAt"
	
	private struct ParseRequestKey {
		static let applicationID = "X-Parse-Application-Id"
		static let apiKey = "X-Parse-REST-API-Key"
	}
	
	private struct ParseRequestValue {
		static let applicationID = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
		static let apiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"
	}
	
	//MARK: Properties
	
	let session = URLSession.shared
	var needsRefresh = true
	var studentRecords = [StudentRecord]()
	var loggedInStudentRecordID: String? = nil
	
	//MARK: Functions
	
	func getRecordInCache(fromIndex index: Int) -> StudentRecord? {
		if (index >= studentRecords.count) {
			print("Student record index out of bounds.")
			return nil
		}
		return studentRecords[index]
	}
	
	func getStudentRecords(_ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		
		let urlString = Url.studentLocation + "?\(getLast100Query)"
		let request = getParseRequest(urlString)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			
			self.needsRefresh = false
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			guard let response:StudentRecordsResponse = JSONParser.decode(data!) else {
				completion(false, DisplayError.unexpected)
				return
			}
			
			//some of the Parse server's records have missing properties, so filter out invalid records
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
	
	func getLoggedInStudentRecord(_ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		
		let query = UserByUdacityIDQuery()
		let queryString = JSONParser.stringify(query).addingPercentEncoding(withAllowedCharacters: .urlPathAllowed)!
		let urlString = "\(Url.studentLocation)?where=\(queryString)"
		let request = getParseRequest(urlString)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			guard let response:StudentRecordsResponse = JSONParser.decode(data!) else {
				completion(false, DisplayError.unexpected)
				return
			}
			
			if response.results.count > 0 {
				self.loggedInStudentRecordID = response.results[0].objectId
			}
			
			completion(true, nil)
		}
		task.resume()
	}
	
	func setStudentRecord(_ mapString: String,
	                      _ latitude: Double,
	                      _ longitude: Double,
	                      _ mediaUrl: String,
	                      _ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		
		var request: NSMutableURLRequest
		if loggedInStudentRecordID == nil {
			request = getParseRequest(Url.studentLocation)
			request.httpMethod = WebMethod.post
		} else {
			request = getParseRequest(Url.studentLocation + "/" + loggedInStudentRecordID!)
			request.httpMethod = WebMethod.put
		}
		
		request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.contentType)
		
		let newRecord = StudentRecordRequest(mapString, mediaUrl, latitude, longitude)
		request.httpBody = JSONParser.stringify(newRecord).data(using: String.Encoding.utf8)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			
			self.needsRefresh = true
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			completion(true, nil)
		}
		task.resume()
	}
	
	private func getParseRequest(_ urlString: String) -> NSMutableURLRequest {
		let request = NSMutableURLRequest(url: URL(string: urlString)!)
		request.addValue(ParseRequestValue.applicationID, forHTTPHeaderField: ParseRequestKey.applicationID)
		request.addValue(ParseRequestValue.apiKey, forHTTPHeaderField: ParseRequestKey.apiKey)
		return request
	}
	
	//MARK: Request structs
	
	private struct UserByUdacityIDQuery: Codable {
		let uniqueKey: String
		
		init() {
			uniqueKey = UdacityClient.shared.udacityAccountKey!
		}
	}
	
	private struct StudentRecordRequest: Codable {
		let uniqueKey: String
		let firstName: String
		let lastName: String
		let mapString: String
		let mediaURL: String
		let latitude: Double
		let longitude: Double
		
		init(_ mapString: String, _ mediaURL: String, _ latitude: Double, _ longitude: Double) {
			self.uniqueKey = UdacityClient.shared.udacityAccountKey!
			self.firstName = UdacityClient.shared.udacityFirstName!
			self.lastName = UdacityClient.shared.udacityLastName!
			self.mapString = mapString
			self.mediaURL = mediaURL
			self.latitude = latitude
			self.longitude = longitude
		}
	}
	
	//MARK: Response structs
	
	private struct StudentRecordsResponse : Codable {
		var results: [StudentRecordResponse]
	}
	
	struct StudentRecordResponse: Codable {
		var createdAt: String?
		var firstName: String?
		var lastName: String?
		var latitude: Double?
		var longitude: Double?
		var mapString: String?
		var mediaURL: String?
		var objectId: String?
		var uniqueKey: String?
		var updatedAt: String?
	}
}

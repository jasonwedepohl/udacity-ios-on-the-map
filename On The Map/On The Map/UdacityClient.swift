//
//  UdacityClient.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/18.
//
//

import Foundation
import FacebookCore
import FacebookLogin

class UdacityClient {
	
	//MARK: Singleton
	
	static let shared = UdacityClient()
	
	//MARK: Constants
	
	let responseHeaderLength = 5
	
	struct Url {
		static let session = "https://www.udacity.com/api/session"
	}
	
	struct ResponseKeys {
		static let account = "account";
		static let key = "key";
		static let session = "session";
		static let id = "id";
	}
	
	//MARK: Properties
	
	let session = URLSession.shared
	
	var udacitySessionID: String? = nil
	var udacityAccountKey: String? = nil
	
	func login(email: String, password: String, completion: @escaping (_ success: Bool) -> Void) {
		let httpBodyString = "{\"udacity\": {\"username\": \"\(email)\", \"password\": \"\(password)\"}}"
		let request = getLoginRequest(withBody: httpBodyString)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			self.handleLoginTaskCompletion(data, response, error, completion)
		}
		task.resume()
	}
	
	func loginWithFacebook(completion: @escaping (_ success: Bool) -> Void) {
		guard let accessToken = AccessToken.current?.authenticationToken else {
			print("The Facebook access token is not set.")
			completion(false)
			return
		}
		
		let httpBodyString = "{\"facebook_mobile\": {\"access_token\": \"\(accessToken)\"}}"
		let request = getLoginRequest(withBody: httpBodyString)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			self.handleLoginTaskCompletion(data, response, error, completion)
		}
		task.resume()
	}
	
	func logout(completion: @escaping (_ success: Bool) -> Void) {
		//log out of Facebook if necessary
		if (AccessToken.current != nil) {
			let loginManager = LoginManager()
			loginManager.logOut()
		}
		
		let request = NSMutableURLRequest(url: URL(string: Url.session)!)
		request.httpMethod = WebMethod.delete
		
		if let xsrfCookie = getCookie(withKey: Cookie.xsrfToken) {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: RequestKey.xxsrfToken)
		}
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			guard let jsonResponse = self.getJsonResponse(data, response, error) else {
				print("Could not get a valid JSON response.")
				completion(false)
				return
			}
			
			print("\(jsonResponse)")
			
			completion(true)
		}
		task.resume()
	}
	
	private func getLoginRequest(withBody body: String) -> NSMutableURLRequest {
		let request = NSMutableURLRequest(url: URL(string: Url.session)!)
		request.httpMethod = WebMethod.post
		request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.accept)
		request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.contentType)
		request.httpBody = body.data(using: String.Encoding.utf8)
		return request
	}
	
	private func handleLoginTaskCompletion(_ data: Data?,
	                                       _ response: URLResponse?,
	                                       _ error: Error?,
	                                       _ completion: @escaping (_ success: Bool) -> Void) {
		
		guard let jsonResponse = self.getJsonResponse(data, response, error) else {
			print("Could not get a valid JSON response.")
			completion(false)
			return
		}
		
		guard let dictionaryResponse = jsonResponse as? [String:AnyObject] else {
			print("Could not get response dictionary from response \(jsonResponse)")
			completion(false)
			return
		}
		
		guard let account = dictionaryResponse[ResponseKeys.account] as? [String:AnyObject] else {
			print("Could not get account from response \(jsonResponse)")
			completion(false)
			return
		}
		
		guard let accountKey = account[ResponseKeys.key] as? String else {
			print("Could not get account key from response \(jsonResponse)")
			completion(false)
			return
		}
		
		guard let session = dictionaryResponse[ResponseKeys.session] as? [String:AnyObject] else {
			print("Could not get session from response \(jsonResponse)")
			completion(false)
			return
		}
		
		guard let sessionID = session[ResponseKeys.id] as? String else {
			print("Could not get account key from response \(jsonResponse)")
			completion(false)
			return
		}
		
		self.udacityAccountKey = accountKey
		self.udacitySessionID = sessionID
		
		print("Session ID: \(self.udacitySessionID!), Account key: \(self.udacityAccountKey!)")
		
		completion(true)
	}
	
	private func getJsonResponse(_ data: Data?, _ response: URLResponse?, _ error: Error?) -> AnyObject? {
		//check no error was returned, status code was 2xx, and data was returned
		guard let validData = Utilities.getValidResponseData(data, response, error) else {
			return nil
		}
		
		//subset response
		let range = Range(responseHeaderLength..<validData.count)
		let subsetResponseData = validData.subdata(in: range)
		
		//parse response to JSON
		guard let jsonResponse = Utilities.getJson(subsetResponseData) else {
			return nil
		}
		
		return jsonResponse
	}
	
	private func getCookie(withKey key: String) -> HTTPCookie? {
		let sharedCookieStorage = HTTPCookieStorage.shared
		for cookie in sharedCookieStorage.cookies! {
			if cookie.name == key {
				return cookie
			}
		}
		return nil
	}
}

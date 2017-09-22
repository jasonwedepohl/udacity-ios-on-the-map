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
	
	//MARK: Properties
	
	let session = URLSession.shared
	
	var udacitySessionID: String? = nil
	var udacityAccountKey: String? = nil
	
	//MARK: Functions
	
	func login(email: String, password: String, completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		let requestBody = UdacityLoginRequest.get(email, password)
		let request = getLoginRequest(withBody: requestBody)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			self.handleLoginTaskCompletion(data, response, error, completion)
		}
		task.resume()
	}
	
	func loginWithFacebook(completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		guard let accessToken = AccessToken.current?.authenticationToken else {
			print("The Facebook access token is not set.")
			completion(false, DisplayError.unexpected)
			return
		}
		
		let requestBody = UdacityLoginWithFacebookRequest.get(accessToken)
		let request = getLoginRequest(withBody: requestBody)
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			self.handleLoginTaskCompletion(data, response, error, completion)
		}
		task.resume()
	}
	
	func logout(completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		
		//log out of Facebook if necessary
		if (AccessToken.current != nil) {
			let loginManager = LoginManager()
			loginManager.logOut()
		}
		
		let request = NSMutableURLRequest(url: URL(string: Url.session)!)
		request.httpMethod = WebMethod.delete
		
		//add anti-XSRF cookie so Udacity server knows this is the client that originally logged in
		if let xsrfCookie = Utilities.getCookie(withKey: Cookie.xsrfToken) {
			request.setValue(xsrfCookie.value, forHTTPHeaderField: RequestKey.xxsrfToken)
		}
		
		let task = session.dataTask(with: request as URLRequest) { data, response, error in
			
			let responseHandler = ResponseHandler(data, response, error)
			
			if let responseError = responseHandler.getResponseError() {
				completion(false, responseError)
				return
			}
			
			completion(true, nil)
		}
		task.resume()
	}
	
	private func getLoginRequest<T: Encodable>(withBody body: T) -> NSMutableURLRequest {
		let request = NSMutableURLRequest(url: URL(string: Url.session)!)
		request.httpMethod = WebMethod.post
		request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.accept)
		request.addValue(RequestValue.jsonType, forHTTPHeaderField: RequestKey.contentType)
		request.httpBody = JSONParser.stringify(body).data(using: String.Encoding.utf8)
		return request
	}
	
	private func handleLoginTaskCompletion(_ data: Data?,
	                                       _ response: URLResponse?,
	                                       _ error: Error?,
	                                       _ completion: @escaping (_ success: Bool, _ displayError: String?) -> Void) {
		
		let responseHandler = ResponseHandler(data, response, error)
		
		if let responseError = responseHandler.getResponseError() {
			completion(false, responseError)
			return
		}
		
		//subset response
		let range = Range(responseHeaderLength..<data!.count)
		let subsetResponseData = data!.subdata(in: range)
		
		guard let response:UdacityLoginResponse = JSONParser.decode(subsetResponseData) else {
			completion(false, DisplayError.unexpected)
			return
		}
		
		self.udacityAccountKey = response.account.key
		self.udacitySessionID = response.session.id
		
		completion(true, nil)
	}
	
	//MARK: Request structs
	
	private struct UdacityLoginRequest: Codable {
		private let udacity : Udacity
		
		private struct Udacity : Codable {
			let username: String
			let password: String
		}
		
		static func get(_ username: String, _ password: String) -> UdacityLoginRequest {
			return UdacityLoginRequest(udacity: Udacity(username: username, password: password))
		}
	}
	
	private struct UdacityLoginWithFacebookRequest: Codable {
		private let facebook_mobile : FacebookMobile
		
		private struct FacebookMobile : Codable {
			let access_token: String
		}
		
		static func get(_ accessToken: String) -> UdacityLoginWithFacebookRequest {
			return UdacityLoginWithFacebookRequest(facebook_mobile: FacebookMobile(access_token: accessToken))
		}
	}
	
	//MARK: Response structs
	
	private struct UdacityLoginResponse: Codable {
		
		let account: Account
		let session: Session
		
		struct Account: Codable {
			let registered: Bool
			let key: String
		}
		
		struct Session: Codable {
			let id: String
			let expiration: String
		}
	}
}

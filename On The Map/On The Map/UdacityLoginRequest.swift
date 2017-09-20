//
//  UdacityLoginRequest.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/20.
//

import Foundation

struct UdacityLoginRequest: Codable {
	private let udacity : Udacity
	
	private struct Udacity : Codable {
		let username: String
		let password: String
	}
	
	static func get(_ username: String, _ password: String) -> UdacityLoginRequest {
		return UdacityLoginRequest(udacity: Udacity(username: username, password: password))
	}
}

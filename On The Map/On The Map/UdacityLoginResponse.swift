//
//  UdacitySessionResponse.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/20.
//

import Foundation

struct UdacityLoginResponse: Codable {
	
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

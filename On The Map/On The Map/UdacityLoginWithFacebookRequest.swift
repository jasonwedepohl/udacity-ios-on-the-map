//
//  UdacityLoginWithFacebookRequest.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/20.
//

import Foundation

struct UdacityLoginWithFacebookRequest: Codable {
	private let facebook_mobile : FacebookMobile
	
	private struct FacebookMobile : Codable {
		let access_token: String
	}
	
	static func get(_ accessToken: String) -> UdacityLoginWithFacebookRequest {
		return UdacityLoginWithFacebookRequest(facebook_mobile: FacebookMobile(access_token: accessToken))
	}
}

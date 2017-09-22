//
//  WebMethod.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/19.
//
//

import Foundation

struct WebMethod {
	static let get = "GET";
	static let post = "POST";
	static let delete = "DELETE";
}

struct RequestKey {
	static let accept = "Accept";
	static let contentType = "Content-Type";
	static let xxsrfToken = "X-XSRF-TOKEN";
}

struct RequestValue {
	static let jsonType = "application/json";
}

struct Cookie {
	static let xsrfToken = "XSRF-TOKEN";
}

struct DisplayError {
	static let unexpected = "An unexpected error occurred."
	static let network = "Could not connect to the Internet."
	static let credentials = "Incorrect email or password."
}

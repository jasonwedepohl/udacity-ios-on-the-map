//
//  StudentRecordResponse.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

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

//
//  StudentLocationResponse.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/21.
//

import Foundation

struct StudentRecordsResponse : Codable {
	var results: [StudentRecordResponse]

	var studentRecords: [StudentRecord] {
		
		//some of the Parse server's records have missing properties, so filter them out
		let validResponseResults = results.filter {
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
		
		return validResponseResults.map { StudentRecord($0) }
	}
}

//
//  StudentRecordCache.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/28.
//

import Foundation

class StudentRecordCache {
	static let instance = StudentRecordCache()
	
	private var studentRecords = [StudentRecord]()
	
	func set(_ records: [StudentRecord]) {
		studentRecords = records
	}
	
	func getAll() -> [StudentRecord] {
		return studentRecords
	}
	
	func get(fromIndex index: Int) -> StudentRecord? {
		if (index >= studentRecords.count) {
			print("Student record index out of bounds.")
			return nil
		}
		return studentRecords[index]
	}
}

//
//  StudentStore.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/22.
//

import UIKit

class StudentRecordCache {
	
	static let instance = StudentRecordCache()
	
	func get(fromIndex index: Int) -> StudentRecord? {
		let records = getAll()
		guard index < records.count else {
			print("Meme index was out of bounds.")
			return nil
		}
		return records[index]
	}
	
	func getAll() -> [StudentRecord] {
		guard let records = getAppDelegate().studentRecords else {
			print("Student records are not loaded.")
			return [StudentRecord]()
		}
		return records
	}
	
	func set(_ records: [StudentRecord]) {
		getAppDelegate().studentRecords = records
	}
	
	private func getAppDelegate() -> AppDelegate {
		return UIApplication.shared.delegate as! AppDelegate
	}
}

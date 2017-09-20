//
//  JSONParser.swift
//  On The Map
//
//  Created by Jason Wedepohl on 2017/09/20.
//

import Foundation

class JSONParser {
	static func stringify<T: Encodable>(_ codable: T) -> String {
		do {
			let jsonData = try JSONEncoder().encode(codable)
			return String(data: jsonData, encoding: .utf8)!
		}
		catch {
			print("Could not encode the given object to JSON: \(error.localizedDescription)")
			return ""
		}
	}
	
	static func decode<T : Decodable>(_ data: Data) -> T? {
		do {
			return try JSONDecoder().decode(T.self, from: data)
		}
		catch {
			print("Could not decode the given data to type \(T.self): \(error.localizedDescription)")
			return nil
		}
	}
}

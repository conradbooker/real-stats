//
//  TimeModel.swift
//  real-stats
//
//  Created by Conrad on 4/1/23.
//

import Foundation

struct NewTimes: Hashable, Codable {
    var service: Bool
    var north: [String: [String: NewStationTime]?]?
    var south: [String: [String: NewStationTime]?]?
}

struct NewStationTime: Hashable, Codable {
    var tripID: String
    var destination: String
}

struct Time: Hashable, Codable {
    var north: [Times]
    var south: [Times]
}

struct Times: Hashable, Codable {
    var line: String
    var times: [Indv]
}

struct Indv: Hashable, Codable {
    var currentStationTime: Int
    var tripID: String
    var destinationID: String
    var countdown: Int
}

extension String {
  func decodeJson <T: Decodable> (_ type : T.Type ,
  dateDecodingStrategy: JSONDecoder.DateDecodingStrategy = .deferredToDate,
  keyDecodingStrategy: JSONDecoder.KeyDecodingStrategy = .useDefaultKeys) -> T {
        
     let jsonData = self.data(using: .utf8)!
       
      do {
         let decoder = JSONDecoder()
         decoder.dateDecodingStrategy = dateDecodingStrategy
         decoder.keyDecodingStrategy = keyDecodingStrategy
   
         let result = try decoder.decode(type, from: jsonData)
         return result
      }
      catch {
          fatalError("err:\(error)")
      }
   }
}

//
//  Header+FromJSON.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/1/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import SwiftJWT

extension Header {
  enum HeaderError: Error {
    case jsonError(String)
    case invalidKeyError(String)
  }
  
  static func FromJSON(json: String) throws -> Header {
    var dict: [String: Any]
    
    guard let jsonData = json.data(using: .utf8) else {
      throw HeaderError.jsonError("Invalid JSON")
    }
    
    do {
      dict = try (JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:])
    } catch {
      throw HeaderError.jsonError("Invalid JSON")
    }
    
    dict.removeValue(forKey: "alg")
    
    let header = Header.init(
      typ: dict["typ"] as? String,
      jku: dict["jku"] as? String,
      jwk: dict["jwk"] as? String,
      kid: dict["kid"] as? String,
      x5u: dict["x5u"] as? String,
      x5c: dict["x5c"] as? [String],
      x5t: dict["x5t"] as? String,
      x5tS256: dict["x5tS256"] as? String,
      cty: dict["cty"] as? String,
      crit: dict["crit"] as? [String]
    )
    
    dict.removeValue(forKey: "typ")
    dict.removeValue(forKey: "jku")
    dict.removeValue(forKey: "jwk")
    dict.removeValue(forKey: "kid")
    dict.removeValue(forKey: "x5u")
    dict.removeValue(forKey: "x5c")
    dict.removeValue(forKey: "x5t")
    dict.removeValue(forKey: "x5tS256")
    dict.removeValue(forKey: "cty")
    dict.removeValue(forKey: "crit")
    
    if dict.count == 0 {
      return header
    } else {
      let keys = dict.keys.joined(separator: ", ")
      throw HeaderError.invalidKeyError("Invalid key: \(keys)")
    }
  }
}

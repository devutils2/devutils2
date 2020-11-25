//
//  URL.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/9/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

extension URL {
  var queryDictionary: [String: String]? {
    guard let query = self.query else { return nil}
    
    var queryStrings = [String: String]()
    for pair in query.components(separatedBy: "&") {
      
      let key = pair.components(separatedBy: "=")[0]
      
      let value = pair
        .components(separatedBy:"=")[1]
        .replacingOccurrences(of: "+", with: " ")
        .removingPercentEncoding ?? ""
      
      queryStrings[key] = value
    }
    return queryStrings
  }
}

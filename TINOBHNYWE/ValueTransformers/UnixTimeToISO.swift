//
//  UnixTimeToISO.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/28/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import SwiftDate

class UnixTimeToISOString: ValueTransformer {
  
  // Accept value as Int or String, use it as unix time to convert it to ISO
  override func transformedValue(_ value: Any?) -> Any? {
    var parsed: Int?
    let s = value as? Int
    if s != nil {
      parsed = s
    } else {
      let s2 = value as? String
      if s2 != nil {
        parsed = Int(s2!)
        if parsed == nil {
          return "Invalid"
        }
      } else {
        return "Invalid"
      }
    }

    let dateInRegion = DateInRegion.init(seconds: .init(parsed!), region: .UTC)
    return dateInRegion.toISO(.none)
  }
}

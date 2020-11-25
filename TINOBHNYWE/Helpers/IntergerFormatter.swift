//
//  IntergerFormatter.swift
//  DevUtils2
//
//  Created by Tony Dinh on 9/29/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class IntegerFormatter: NumberFormatter {
  
  override func isPartialStringValid(_ partialString: String, newEditingString newString: AutoreleasingUnsafeMutablePointer<NSString?>?, errorDescription error: AutoreleasingUnsafeMutablePointer<NSString?>?) -> Bool {
    
    // Allow blank value
    if partialString.count == 0 {
      return true
    }
    
    if partialString.isInt {
      return true
    } else {
      return false
    }
  }
}

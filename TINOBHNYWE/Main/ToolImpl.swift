//
//  ToolImpl.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/13/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class ToolImpl {
  required init() {
  }
}

class ToolOptions {
  var autoDetect: Bool
  
  init(autoDetect: Bool) {
    self.autoDetect = autoDetect
  }
  
  func debugDescription() -> String {
    return """
    ToolOptions
    autoDetect: \(autoDetect)
    """
  }
}

enum ToolError: Error {
    case runtimeError(String)
}

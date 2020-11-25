//
//  FormatToolOptions.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class FormatToolOptions: ToolOptions {
  enum FormatMode {
    case twoSpaces
    case fourSpaces
    case oneTab
    case minified
  }
  
  var formatMode: FormatMode
  
  init(formatMode: FormatMode) {
    self.formatMode = formatMode
    super.init(autoDetect: false)
  }
}

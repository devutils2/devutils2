//
//  Base64EndecodeTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/29/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class Base64EndecodeOptions: ToolOptions {
}

class Base64EndecodeTool: EndecodeTool {
  override func encode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let encoded = input.toBase64() else {
      throw ToolError.runtimeError("Cannot encode")
    }
    return encoded
  }
  
  override func decode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let decoded = input.fromBase64() else {
      throw ToolError.runtimeError("Cannot decode")
    }
    return decoded
  }
}

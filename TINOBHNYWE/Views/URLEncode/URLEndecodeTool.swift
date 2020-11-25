//
//  URLEndecodeTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/30/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class URLEndecodeOptions: ToolOptions {
  var rfc3986: Bool
  var formData: Bool
  var plusForSpace: Bool
  
  init(
    autoDetect: Bool,
    rfc3986: Bool,
    formData: Bool,
    plusForSpace: Bool
    ) {
    self.rfc3986 = rfc3986
    self.formData = formData
    self.plusForSpace = plusForSpace
    super.init(autoDetect: autoDetect)
  }
  
  override func debugDescription() -> String {
    return """
    URLEndecodeOptions
    autoDetect: \(autoDetect)
    rfc3985: \(rfc3986)
    formData: \(formData)
    plusForSpace: \(plusForSpace)
    """
  }
}

class URLEndecodeTool: EndecodeTool {
  override func encode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let ops = toolOptions as? URLEndecodeOptions else {
      log.debug("Wrong options provided \(toolOptions.debugDescription())")
      throw ToolError.runtimeError("Wrong options type provided")
    }
    var encoded: String
    
    if ops.rfc3986 {
      encoded = input.stringByAddingPercentEncodingForRFC3986() ?? ""
    } else if ops.formData {
      if ops.plusForSpace {
        encoded = input.stringByAddingPercentEncodingForFormData(plusForSpace: true) ?? ""
      } else {
        encoded = input.stringByAddingPercentEncodingForFormData() ?? ""
      }
    } else {
      log.debug("Options not well formed: \(ops.debugDescription())")
      throw ToolError.runtimeError("Wrong options provided")
    }
    return encoded
  }
  
  override func decode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let decoded = input.decodeUrl() else {
      throw ToolError.runtimeError("Cannot decode")
    }
    return decoded
  }
  
  override func getSampleString() -> String? {
    return "abc 0123 !@#$%^&*()|+?\"<>',.;:`"
  }
}

//
//  HTMLEntityEndecodeTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/13/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import HTMLEntities

class HTMLEntityEndecodeOptions: ToolOptions {
  var allowUnsafeSymbols: Bool
  var useDecimalFormat: Bool
  var encodeEverything: Bool
  var useNamedReferences: Bool
  var strictDecoding: Bool
  
  override func debugDescription() -> String {
    return """
    HTMLEntityEndecodeOptions
    autoDetect: \(autoDetect)
    allowUnsafeSymbols: \(allowUnsafeSymbols)
    useDecimalFormat: \(useDecimalFormat)
    encodeEverything: \(encodeEverything)
    useNamedReferences: \(useNamedReferences)
    strictDecoding: \(strictDecoding)
    """
  }
  
  init(
    autoDetect: Bool,
    allowUnsafeSymbols: Bool,
    useDecimalFormat: Bool,
    encodeEverything: Bool,
    useNamedReferences: Bool,
    strictDecoding: Bool
  ) {
    self.allowUnsafeSymbols = allowUnsafeSymbols
    self.useDecimalFormat = useDecimalFormat
    self.encodeEverything = encodeEverything
    self.useNamedReferences = useNamedReferences
    self.strictDecoding = strictDecoding
    
    super.init(autoDetect: autoDetect)
  }
}

class HTMLEntityEndecodeTool: EndecodeTool {
  
  override func getSampleString() -> String? {
    return "<h1>Hello</h1>"
  }
  
  override func encode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let options = toolOptions as? HTMLEntityEndecodeOptions else {
      log.debug("Failed to cast toolOptions to HTMLEntityEndecodeOptions")
      throw ToolError.runtimeError("Failed to cast toolOptions to HTMLEntityEndecodeOptions")
    }
    
    return input.htmlEscape(
      allowUnsafeSymbols: options.allowUnsafeSymbols,
      decimal: options.useDecimalFormat,
      encodeEverything: options.encodeEverything,
      useNamedReferences: options.useNamedReferences
    )
  }

  override func decode(_ input: String, _ toolOptions: ToolOptions) throws -> String {
    guard let options = toolOptions as? HTMLEntityEndecodeOptions else {
      log.debug("Failed to cast toolOptions to HTMLEntityEndecodeOptions")
      throw ToolError.runtimeError("Failed to cast toolOptions to HTMLEntityEndecodeOptions")
    }
    return try input.htmlUnescape(strict: options.strictDecoding)
  }
}

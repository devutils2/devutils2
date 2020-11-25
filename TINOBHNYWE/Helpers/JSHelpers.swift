//
//  JSONHelper.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/8/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class JSHelpers {
  public static func readScript(_ scriptName: String) -> String {
    if let filepath = Bundle.main.path(forResource: scriptName, ofType: "js") {
      do {
        let contents = try String(contentsOfFile: filepath)
        return contents
      } catch {
        log.error("\(scriptName) could not be loaded")
      }
    } else {
      log.error("\(scriptName) not found")
    }
    return ""
  }
  
  public static func readJSONFormatter() -> String {
    return readScript("JSONFormatterHelper")
  }
  
  public static func readPrettyDiff() -> String {
    return readScript("prettydiff.browser.min")
  }
}

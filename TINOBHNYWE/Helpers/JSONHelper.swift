//
//  JSONHelper.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/8/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class JSONHelper {
  public static func jsonFormatterCode() -> String {
    if let filepath = Bundle.main.path(forResource: "JSONFormatterHelper", ofType: "js") {
      do {
        let contents = try String(contentsOfFile: filepath)
        return contents
      } catch {
        // contents could not be loaded
        log.error("jsonHelper.js could not be loaded")
      }
    } else {
      // example.txt not found!
      log.error("jsonHelper.js not found")
    }
    return ""
  }
}

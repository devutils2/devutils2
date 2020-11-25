//
//  HTMLFormatterTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

class HTMLFormatterTool: PrettydiffFormatterTool {
  override func getSampleString() -> String? {
    return """
    <!DOCTYPE html><html><body><style>h1{color:blue;}</style><h1>Hello from DevUtils2.app!</h1><p>This is a sample HTML page. By default, JavaScript and link navigation is disabled. You can click the gear icon to enable it.</p><p>Right click > Inspect Element also works.</p></body></html>
    """
  }
  
  override func getHighlighterLanguage() -> String {
    return "html"
  }

  override func format(input: String, options: FormatToolOptions) throws -> String {
    return try formatLanguage(input: input, options: options, language: "html")
  }
}

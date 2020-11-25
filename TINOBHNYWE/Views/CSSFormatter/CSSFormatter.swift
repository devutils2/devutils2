//
//  CSSFormatter.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import JavaScriptCore

class CSSFormatterTool: PrettydiffFormatterTool {
  override func getSampleString() -> String? {
    return """
    @font-face{font-family:Chunkfive;src:url('Chunkfive.otf');}body,.usertext{color:#F0F0F0;background:#600;font-family:Chunkfive,sans;--heading-1:30px / 32px Helvetica,sans-serif;}@import url('print.css');@media print{a[href^=http]::after{content:attr(href)x;}}
    """
  }
  
  override func getHighlighterLanguage() -> String {
    return "less" // "css" won't work
  }

  override func format(input: String, options: FormatToolOptions) throws -> String {
    return try formatLanguage(input: input, options: options, language: "css")
  }
}

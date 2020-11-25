//
//  PrettydiffFormatterTool.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import JavaScriptCore

class PrettydiffFormatterTool: FormatterTool {
  private func setModeCharSize(_ c: JSContext, _ mode: String, _ char: String, _ size: Int) {
    c.setObject(mode, forKeyedSubscript: "mode" as NSString)
    c.setObject(char, forKeyedSubscript: "indent_char" as NSString)
    c.setObject(size, forKeyedSubscript: "indent_size" as NSString)
  }
  
  func formatLanguage(input: String, options: FormatToolOptions, language: String) throws -> String {
    let c = JSContext()!
    c.evaluateScript("var window = {};")
    c.evaluateScript(JSHelpers.readPrettyDiff())
    c.setObject(input, forKeyedSubscript: "input" as NSString)
    c.setObject(language, forKeyedSubscript: "language" as NSString)
    
    if options.formatMode == .twoSpaces {
      setModeCharSize(c, "beautify", " ", 2)
    } else if options.formatMode == .fourSpaces {
      setModeCharSize(c, "beautify", " ", 4)
    } else if options.formatMode == .oneTab {
      setModeCharSize(c, "beautify", "\t", 1)
    } else if options.formatMode == .minified {
      setModeCharSize(c, "minify", "", 0)
    } else {
      log.error("unhandled format mode")
    }
    
    let result = c.evaluateScript(
      """
      (function() {
        try {
          var output     = "",
              prettydiff = window.prettydiff,
              options    = prettydiff.options;
          options.source = input;
          options.language = language;
          options.mode = mode;
          options.indent_char = indent_char;
          options.indent_size = indent_size;
          options.css_insert_lines = true;
          return prettydiff();
        } catch (e) {
          return e;
        }
      })();
      """
    )?.toString()
    
    return result ?? ""
  }
}

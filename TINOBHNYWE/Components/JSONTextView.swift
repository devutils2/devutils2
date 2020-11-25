//
//  JSONTextView.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/30/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import Highlightr

class JSONTextView: WrapableTextView {
  
  var highlightr: Highlightr! = Highlightr()
  var enableHighlight: Bool = true
  var currentFormat: Int?
  var currentSpaces: Bool = true
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    setTheme()
    
    DistributedNotificationCenter.default.addObserver(
      self,
      selector: #selector(interfaceModeChanged(sender:)),
      name: NSNotification.Name(
        rawValue: "AppleInterfaceThemeChangedNotification"),
      object: nil)
  }

  func setHighlight(_ value: Bool) {
    self.enableHighlight = value
  }
  
  // format = nil means compact (minified)
  func setJSONString(_ value: String, format: Int? = 2, spaces: Bool = true, allowWeakJSON: Bool = false) -> [JSONParseError] {
    currentFormat = format
    currentSpaces = spaces
    var errors: [JSONParseError] = []
    let output = value.pretifyJSONv2(
      format: format,
      spaces: spaces,
      allowWeakJSON: allowWeakJSON,
      errors: &errors
    )
    
    if output != nil && output != "undefined" {
      self.string = ""
      if self.enableHighlight {
        if let attributedString = highlightr.highlight(output!, as: "json") {
          self.textStorage?.setAttributedString(attributedString)
        }
      } else {
        self.string = output!
      }
      
      highlightErrors(errors)
    } else {
      self.string = "Invalid JSON"
    }
    
    return errors
  }
  
  // validate the current value of the text view
  func validateJSON(highlight: Bool = true, allowWeakJSON: Bool = false) -> [JSONParseError] {
    var errors: [JSONParseError] = []
    let _ = self.string.pretifyJSONv2(
      format: nil,
      spaces: true,
      allowWeakJSON: allowWeakJSON,
      errors: &errors
    )
    if highlight {
      resetTextAttributes()
      highlightErrors(errors)
    }
    return errors
  }
  
  func resetTextAttributes() {
    let allOfIt = NSRange.init(location: 0, length: textStorage?.length ?? 0)
    self.textStorage?.removeAttribute(.backgroundColor, range: allOfIt)
    self.textStorage?.removeAttribute(.underlineStyle, range: allOfIt)
    self.textStorage?.addAttributes(
      [
        NSAttributedString.Key.foregroundColor: NSColor.textColor
      ],
      range: allOfIt
    )
  }
  
  func highlightErrors(_ errors: [JSONParseError]) {
    errors.forEach { (e) in
      self.textStorage?.addAttributes(
        [
          NSAttributedString.Key.backgroundColor: NSColor.red,
          NSAttributedString.Key.foregroundColor: NSColor.black,
          NSAttributedString.Key.underlineStyle: 1,
        ],
        range: .init(location: e.offset, length: e.length)
      )
    }
  }
  
  private func setTheme() {
    if self.hasDarkAppearance {
      highlightr.setTheme(to: "paraiso-dark")
    } else {
      highlightr.setTheme(to: "paraiso-light")
    }
  }
  
  @objc
  func interfaceModeChanged(sender: NSNotification) {
    setTheme()
    let _ = setJSONString(self.string, format: currentFormat, spaces: currentSpaces)
  }
  
  deinit {
    DistributedNotificationCenter.default().removeObserver(
      self,
      name: NSNotification.Name(
        rawValue: "AppleInterfaceThemeChangedNotification"),
      object: nil)
  }
}

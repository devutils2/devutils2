//
//  CopiableTextView.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/18/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class OutputTextField: CustomView {
  @IBOutlet weak var textField: NSTextField!
  @IBOutlet weak var copyButton: NSButtonCell!
  
  public func setValue(_ value: String) {
    textField.stringValue = value
  }
  
  public func getValue() -> String {
    return textField.stringValue
  }
  
  @IBAction func copyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(textField.stringValue, forType: .string)
  }
}

//
//  ToolViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/25/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class ToolViewController: NSViewController {
  var pendingInput: ActivationValue? = nil
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  required init(nibName: NSNib.Name?) {
    super.init(nibName: nibName, bundle: nil)
  }
  
  func clearPendingInput() {
    pendingInput = nil
  }
  
  func activate(input: ActivationValue) {
  }
  
  func matchInput(input: String) -> Bool {
    return false
  }
  
  func ensureDefault(_ forceDefaults: Bool = false) {
    
  }
}

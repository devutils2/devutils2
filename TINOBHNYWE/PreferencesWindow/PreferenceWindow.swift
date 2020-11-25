//
//  PreferenceWindow.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/4/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import Carbon.HIToolbox

class PreferenceWindow: NSWindow {
  override func keyDown(with event: NSEvent) {
    if event.keyCode == kVK_Escape {
      close()
    } else {
      super.keyUp(with: event)
    }
  }
}

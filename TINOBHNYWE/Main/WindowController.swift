//
//  WindowController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/15/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class WindowController: NSWindowController, NSWindowDelegate {
  func windowDidBecomeMain(_ notification: Notification) {
    self.window?.title = "https://DevUtils2.app - Developer Utilities for MacOS \(AppState.getAppVersion())"
  }
}

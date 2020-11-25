//
//  GeneralHelpers.swift
//  DevUtils2
//
//  Created by Tony Dinh on 9/29/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class GeneralHelpers {
  static func confirm(question: String, text: String) -> Bool {
    let alert = NSAlert()
    alert.messageText = question
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.addButton(withTitle: "Cancel")
    return alert.runModal() == .alertFirstButtonReturn
  }
  
  static func alert(title: String, text: String) {
    let alert = NSAlert()
    alert.messageText = title
    alert.informativeText = text
    alert.alertStyle = .warning
    alert.addButton(withTitle: "OK")
    alert.runModal()
  }
  
  static func loadFileAsUTF8(title: String) -> String? {
    let dialog = NSOpenPanel();
    
    dialog.title                   = title
    dialog.showsResizeIndicator    = true
    dialog.showsHiddenFiles        = true
    dialog.canChooseDirectories    = true
    dialog.canCreateDirectories    = false
    dialog.allowsMultipleSelection = false
    
    if (dialog.runModal() == NSApplication.ModalResponse.OK) {
      if let url = dialog.url {
        do {
          return try String(contentsOf: url, encoding: .utf8)
        } catch {
          log.error("Failed to read file: \(error)")
          let alert = NSAlert()
          alert.messageText = "Cannot read the file."
          alert.informativeText = "The file cannot be read because of this reason: " + error.localizedDescription
          alert.alertStyle = .warning
          alert.addButton(withTitle: "OK")
          alert.runModal()
        }
      }
    } else {
      // User clicked on "Cancel"
    }
    
    return nil
  }
}

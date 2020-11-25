//
//  WelcomeViewController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/20/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class WelcomeViewController: ToolViewController {
  @IBOutlet weak var tipLabel: NSTextField!
  @IBOutlet weak var preferenceLabel: NSTextField!
  @IBOutlet weak var preferenceButton: NSButton!
  @IBOutlet var inputTextView: NSTextView!
  @IBOutlet weak var inputBox: NSBox!
  @IBOutlet weak var currentInputLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(refreshContent),
      name: PreferencesViewController.NotificationNames.userDefaultsChanged,
      object: nil)
    inputTextView.setMonoFont()
    inputTextView.nicePadding()
    refreshContent()
  }
  
  override func matchInput(input: String) -> Bool {
    return true
  }
  
  override func activate(input: ActivationValue) {
    if input.value == "" {
      inputBox.isHidden = true
      return
    }
    inputTextView.string = input.value
    inputBox.isHidden = false
    var source: String = ""
    if input.source == .clipboard {
      source = " (from clipboard)"
    } else if input.source == .service {
      source = " (from text selection)"
    } else if input.source == .manual {
      source = " (user entered)"
    }
    currentInputLabel.stringValue = "No tool was detected for this input\(source):"
  }
  
  @IBAction func preferenceButtonAction(_ sender: Any) {
    ((NSApplication.shared.delegate) as! AppDelegate).openPreferenceWindow()
  }
  
  @objc
  func refreshContent() {
    let shortcut = AppState.getGlobalHotkeyPreference().description
    tipLabel.stringValue = "Press \(shortcut) to show/hide this window"
    
    if !AppState.shouldShowDockIcon() {
      preferenceLabel.isHidden = true
      preferenceButton.isHidden = false
    } else {
      preferenceLabel.isHidden = false
      preferenceButton.isHidden = true
    }
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.string = ""
    inputBox.isHidden = true
  }
  
  @IBAction func copyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(inputTextView.string, forType: .string)
  }
}

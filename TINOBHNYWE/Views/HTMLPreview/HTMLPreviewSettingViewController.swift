//
//  HTMLPreviewSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/4/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class HTMLPreviewOptions: ToolOptions {
  var enableJavaScript: Bool
  var enableNavigation: Bool
  var enableNetwork: Bool

  init(enableJavaScript: Bool, enableNavigation: Bool, enableNetwork: Bool) {
    self.enableJavaScript = enableJavaScript
    self.enableNavigation = enableNavigation
    self.enableNetwork = enableNetwork
    super.init(autoDetect: false)
  }
}

class HTMLPreviewSettingViewController: ToolSettingViewController {
  @IBOutlet weak var enableRequestCheckbox: NSButton!
  @IBOutlet weak var notSupportedLabel: NSTextField!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    if #available(OSX 10.13, *) {
      enableRequestCheckbox.isEnabled = true
      notSupportedLabel.isHidden = true
    } else {
      enableRequestCheckbox.objectValue = true
      enableRequestCheckbox.isEnabled = false
      notSupportedLabel.isHidden = false
    }
  }
  
  override func getOptions() -> ToolOptions {
    return HTMLPreviewOptions.init(
      enableJavaScript: readBool("html-preview-enable-javascript"),
      enableNavigation: readBool("html-preview-enable-navigation"),
      enableNetwork: readBool("html-preview-enable-network")
    )
  }
  
  @IBAction func checkboxAction(_ sender: Any) {
    delegate?.onOptionsChanged(options: getOptions())
  }
  
  @IBAction func resetToDefaultButton(_ sender: Any) {
    ensureDefaults(true)
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.html-preview-enable-javascript", false, forceDefaults)
    AppState.ensureDefault("values.html-preview-enable-navigation", false, forceDefaults)
    AppState.ensureDefault("values.html-preview-enable-network", false, forceDefaults)
  }
}

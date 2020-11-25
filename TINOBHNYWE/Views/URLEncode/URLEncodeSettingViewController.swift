//
//  URLEncodeSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/30/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class URLEncodeSettingViewController: ToolSettingViewController {
  @IBAction func resetButtonAction(_ sender: Any) {
    ensureDefaults(true)
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  @IBAction func optionsChangedAction(_ sender: NSButton) {
    if sender.identifier?.rawValue == "rfc3986" {
      NSUserDefaultsController.shared.setValue(false, forKeyPath: "values.url-encode-options-form-data")
    } else if sender.identifier?.rawValue == "formData" {
      NSUserDefaultsController.shared.setValue(false, forKeyPath: "values.url-encode-options-rfc3986")
    }
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  override func getOptions() -> ToolOptions? {
    return URLEndecodeOptions.init(
      autoDetect: self.readBool("url-encode-auto-activate-decode"),
      rfc3986: self.readBool("url-encode-options-rfc3986"),
      formData: self.readBool("url-encode-options-form-data"),
      plusForSpace: self.readBool("url-encode-options-plus-for-space")
    )
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.url-encode-auto-activate-decode", true, forceDefaults)
    AppState.ensureDefault("values.url-encode-options-rfc3986", true, forceDefaults)
    AppState.ensureDefault("values.url-encode-options-form-data", false, forceDefaults)
    AppState.ensureDefault("values.url-encode-options-plus-for-space", true, forceDefaults)
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
}

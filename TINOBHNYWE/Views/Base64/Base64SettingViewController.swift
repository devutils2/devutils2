//
//  Base64SettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/7/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class Base64SettingViewController: ToolSettingViewController {
  @IBAction func settingChangedAction(_ sender: Any) {
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  @IBAction func resetToDefaultButtonAction(_ sender: Any) {
    ensureDefaults(true)
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.base64-auto-detect-decode", true, forceDefaults)
  }
  
  override func getOptions() -> ToolOptions? {
    return Base64EndecodeOptions.init(
      autoDetect: self.readBool("base64-auto-detect-decode")
    )
  }
}

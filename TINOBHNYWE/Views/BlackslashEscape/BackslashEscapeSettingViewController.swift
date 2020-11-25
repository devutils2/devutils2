//
//  BackslashEscapeSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 8/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class BackslashEscapeSettingViewController: ToolSettingViewController {
  @IBAction func settingChangedAction(_ sender: Any) {
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  @IBAction func resetToDefaultButtonAction(_ sender: Any) {
    ensureDefaults(true)
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
  }
  
  override func getOptions() -> ToolOptions? {
    return BackslashEscapeToolOptions.init(autoDetect: false)
  }
}

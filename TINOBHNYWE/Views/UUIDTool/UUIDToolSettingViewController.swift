//
//  UUIDToolSettingViewController.swift
//  DevUtils2Tests
//
//  Created by Tony Dinh on 10/2/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class UUIDToolOptions: ToolOptions {
}

class UUIDToolSettingViewController: ToolSettingViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
  }
  
  @IBAction func resetButtonAction(_ sender: Any) {
    ensureDefaults(true)
  }
  
  @IBAction func optionAction(_ sender: Any) {
    self.delegate?.onOptionsChanged(options: self.getOptions() ?? UUIDToolOptions(autoDetect: true))
  }
  
  override func getOptions() -> ToolOptions? {
    return UUIDToolOptions.init(autoDetect: self.readBool("uuid-tool-auto-detect-input-valid"))
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.uuid-tool-auto-detect-input-valid", true, forceDefaults)
  }
}

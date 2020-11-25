//
//  UnixTimeSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/28/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class UnixTimeSettingViewController: ToolSettingViewController {
  
  override func viewDidLoad() {
    UnixTimeViewController.ensureDefaults()
  }
  
  @IBAction func resetToDefaultButtonAction(_ sender: Any) {
    UnixTimeViewController.ensureDefaults(true)
  }
}

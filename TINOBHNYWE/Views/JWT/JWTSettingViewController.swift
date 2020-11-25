//
//  JWTSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/4/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class JWTSettingViewController: ToolSettingViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    JWTViewController.ensureDefaults()
  }
  
  @IBAction func resetToDefaultsButtonAction(_ sender: Any) {
    JWTViewController.ensureDefaults(true)
  }
}

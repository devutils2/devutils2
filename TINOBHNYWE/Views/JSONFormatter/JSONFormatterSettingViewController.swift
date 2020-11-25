//
//  JSONFormatterSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/30/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class JSONFormatterSettingViewController: ToolSettingViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    JSONFormatterViewController.ensureDefaults()
  }
  
  @IBAction func resetButtonAction(_ sender: Any) {
    JSONFormatterViewController.ensureDefaults(true)
  }
}

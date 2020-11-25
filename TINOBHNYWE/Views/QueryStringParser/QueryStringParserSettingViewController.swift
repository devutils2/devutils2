//
//  QueryStringParserSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/10/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class QueryStringParserSettingViewController: ToolSettingViewController {
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // Do view setup here.
    QueryStringParserViewController.ensureDefaults()
  }
  
  @IBAction func resetToDefaultsButtonAction(_ sender: Any) {
    QueryStringParserViewController.ensureDefaults(true)
  }
}

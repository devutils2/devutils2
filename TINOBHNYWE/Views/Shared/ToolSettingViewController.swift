//
//  ToolSettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/13/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

protocol ToolSettingDelegate {
  func onOptionsChanged(options: ToolOptions)
}

class ToolSettingViewController: NSViewController {
  var delegate: ToolSettingDelegate?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  required init(nibName: NSNib.Name?) {
    super.init(nibName: nibName, bundle: nil)
  }
  
  func getOptions() -> ToolOptions? {
    return nil
  }
  
  func ensureDefaults(_ forceDefaults: Bool = false) {
  }
  
  func readBool(_ key: String, _ defaultValue: Bool = false) -> Bool {
    return ToolSettingViewController.readBool(key, defaultValue)
  }
  
  func readString(_ key: String, _ defaultValue: String = "") -> String {
    return ToolSettingViewController.readString(key, defaultValue)
  }
  
  func readInt(_ key: String, _ defaultValue: Int = 0) -> Int {
    return ToolSettingViewController.readInt(key, defaultValue)
  }
  
  static func readBool(_ key: String, _ defaultValue: Bool = false) -> Bool {
    guard let value = NSUserDefaultsController.shared.value(forKeyPath: "values." + key) as? Bool else {
      return defaultValue
    }
    
    return value
  }
  
  static func readString(_ key: String, _ defaultValue: String = "") -> String {
    guard let value = NSUserDefaultsController.shared.value(forKeyPath: "values." + key) as? String else {
      return defaultValue
    }
    
    return value
  }
  
  static func readInt(_ key: String, _ defaultValue: Int = 0) -> Int {
    guard let value = NSUserDefaultsController.shared.value(forKeyPath: "values." + key) as? Int else {
      return defaultValue
    }
    
    return value
  }
}

//
//  HTMLEntitySettingViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/13/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class HTMLEntitySettingViewController: ToolSettingViewController {
  
  @IBAction func settingChangedAction(_ sender: Any) {
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }
  
  override func getOptions() -> ToolOptions? {
    return HTMLEntityEndecodeOptions.init(
      autoDetect: self.readBool("html-entity-options-auto-detect-decodable"),
      allowUnsafeSymbols: self.readBool("html-entity-options-allow-unsafe-symbols"),
      useDecimalFormat: self.readBool("html-entity-options-use-decimal-format"),
      encodeEverything: self.readBool("html-entity-options-encode-everything"),
      useNamedReferences: self.readBool("html-entity-options-use-named-references"),
      strictDecoding: self.readBool("html-entity-options-strict-decoding")
    )
  }
  
  override func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.html-entity-options-auto-detect-decodable", true, forceDefaults)
    AppState.ensureDefault("values.html-entity-options-allow-unsafe-symbols", false, forceDefaults)
    AppState.ensureDefault("values.html-entity-options-use-decimal-format", false, forceDefaults)
    AppState.ensureDefault("values.html-entity-options-encode-everything", false, forceDefaults)
    AppState.ensureDefault("values.html-entity-options-use-named-references", true, forceDefaults)
    AppState.ensureDefault("values.html-entity-options-strict-decoding", false, forceDefaults)
  }
  
  @IBAction func resetToDefaultsButtonAction(_ sender: Any) {
    ensureDefaults(true)
    self.delegate?.onOptionsChanged(options: getOptions()!)
  }

}

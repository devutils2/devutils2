//
//  JSONFormatterViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/23/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import JavaScriptCore

class JSONFormatterViewController: ToolViewController, NSTextViewDelegate, NSTableViewDataSource, NSTableViewDelegate {
  @IBOutlet weak var optionPopUpButton: NSPopUpButton!
  @IBOutlet var inputTextView: JSONTextView!
  @IBOutlet var outputTextView: JSONTextView!
  @IBOutlet weak var errorTableScrollView: NSScrollView!
  @IBOutlet weak var errorTableView: NSTableView!
  
  var settingViewController: JSONFormatterSettingViewController!
  var errors: [JSONParseError] = []

  override func viewDidLoad() {
    super.viewDidLoad()
    inputTextView.setupStandardTextview()
    outputTextView.setupStandardTextview()
    JSONFormatterViewController.ensureDefaults()
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
    
    errorTableView.sizeLastColumnToFit()
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    if !isViewLoaded {
      pendingInput = input
      return
    }
    
    log.debug("JSON tool activated: \(input)")
    inputTextView.string = input.value
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      // This is delayed to avoid an layout issue with the JSONTextView loaded
      // when the viewDidLoad have not finished yet (?)
      // Reproduce this:
      // 1. Copy a JSON text
      // 2. Close app window
      // 3. Press hotkey, app should be activated with JSON tool
      // 4. Select another tool
      // 5. Repeat from step 3
      //
      // Observe the JSONTextView shrinking overtime
      self.refresh()
    }
  }
  
  override func matchInput(input: String) -> Bool {
    guard let autoActivate = NSUserDefaultsController.shared.value(
      forKeyPath: "values.json-formatter-auto-activate-valid-json") as? Bool else {
        log.debug("JSONFormatter auto activate setting not set!")
        return false
    }
    
    let inputString = input
    
    if !autoActivate {
      log.debug("JSONFormatter auto activate disabled")
      return false
    }
    
    guard let jsonData = inputString.data(using: .utf8) else {
      log.debug("JSONFormatter decode the input string")
      return false
    }
    
    do {
      try JSONSerialization.jsonObject(with: jsonData, options: [.allowFragments])
    } catch {
      log.debug("JSONFormatter cannot json deserialize the string: \(error)")
      return false
    }
    
    log.debug("JSONFormatter auto activated")
    return true
  }
  
  override func ensureDefault(_ forceDefaults: Bool = false) {
    JSONFormatterViewController.ensureDefaults(forceDefaults)
  }
  
  static func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.json-formatter-auto-activate-valid-json", true, forceDefaults)
    AppState.ensureDefault("values.json-formatter-allow-trailing-commas-comments", false, forceDefaults)
  }
  
  @IBAction func settingButtonAction(_ sender: NSButton) {
    if settingViewController == nil {
      settingViewController = JSONFormatterSettingViewController(
        nibName: "JSONFormatterSettingViewController"
      )
    }
    
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(NSPasteboard.general.string(forType: .string) ?? "")
    refresh()
  }
  
  @IBAction func loadFileButtonAction(_ sender: Any) {
    if let fileContent = GeneralHelpers.loadFileAsUTF8(title: "Select a JSON file") {
      inputTextView.string = fileContent
      refresh()
    }
  }
  
  @IBAction func copyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(outputTextView.string, forType: .string)
  }
  
  func textDidChange(_ notification: Notification) {
    refresh()
  }
  
  func refresh() {
    self.errors = []
    
    if inputTextView.string == "" {
      outputTextView.string = ""
      refreshError()
      return
    }
    var format: Int? = nil
    var spaces: Bool = true
    
    if optionPopUpButton.titleOfSelectedItem == "4 spaces" {
      format = 4
    } else if optionPopUpButton.titleOfSelectedItem == "2 spaces" {
      format = 2
    }
    
    if optionPopUpButton.titleOfSelectedItem == "1 tab" {
      spaces = false
    }
    
    let allowWeakJSON = NSUserDefaultsController.shared.value(
      forKeyPath: "values.json-formatter-allow-trailing-commas-comments") as? Bool ?? false
    
    let _ = outputTextView.setJSONString(
      inputTextView.string,
      format: format,
      spaces: spaces,
      allowWeakJSON: allowWeakJSON
    )
    
    self.errors = inputTextView.validateJSON(allowWeakJSON: allowWeakJSON)
    refreshError()
  }
  
  func refreshError() {
    if self.errors.count > 0 {
      errorTableScrollView.isHidden = false
      errorTableView.reloadData()
    } else {
      errorTableScrollView.isHidden = true
    }
  }
  
  @IBAction func optionPopUpButtonAction(_ sender: Any) {
    refresh()
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("""
    {"store":{"book":[{"category":"reference", "sold": false,"author":"Nigel Rees","title":"Sayings of the Century","price":8.95},{"category":"fiction","author":"Evelyn Waugh","title":"Sword of Honour","price":12.99},{"category":"fiction","author":"J. R. R. Tolkien","title":"The Lord of the Rings","act": null, "isbn":"0-395-19395-8","price":22.99}],"bicycle":{"color":"red","price":19.95}}}
    """)
    refresh()
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("")
    refresh()
  }
  
  func numberOfRows(in tableView: NSTableView) -> Int {
    return self.errors.count
  }
  
  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    guard let err = self.errors[safe: row] else {
      return nil
    }
    
    if let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "jsonErrorDescription"), owner: nil) as? NSTableCellView {
      cell.textField?.stringValue = err.toString()
      cell.textField?.textColor = .systemRed
      return cell
    }
    
    return nil
  }
  
  @IBAction func errorTableViewAction(_ sender: Any) {
    guard let selectedIndex = errorTableView.selectedRowIndexes.first else {
      inputTextView.setSelectedRange(.init(location: 0, length: 0))
      return
    }
    
    guard let error = self.errors[safe: selectedIndex] else {
      log.error("error table index \(selectedIndex) is selected but couldn't found in self.errors.")
      return
    }
    let range = NSRange.init(
      location: error.offset == inputTextView.string.count ? error.offset - 1 : error.offset,
      length: error.length == 0 ? 1 : error.length
    )
    inputTextView.scrollRangeToVisible(range)
    inputTextView.showFindIndicator(for: range)
  }
  
}

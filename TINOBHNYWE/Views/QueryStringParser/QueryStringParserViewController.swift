//
//  QueryStringParserViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/9/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class QueryStringParserViewController: ToolViewController, NSTextViewDelegate {
  @IBOutlet var inputTextView: NSTextView!
  @IBOutlet var outputTextView: JSONTextView!
  var settingViewController: QueryStringParserSettingViewController!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    inputTextView.setupStandardTextview()
    outputTextView.setupStandardTextview()
    QueryStringParserViewController.ensureDefaults()
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
  }
  
  override func matchInput(input: String) -> Bool {
    if let autoDetectEnabled = NSUserDefaultsController.shared.value(
      forKeyPath: "values.query-string-parser-auto-detect-variables") as? Bool {
      if autoDetectEnabled {
        return parseQueryString(input).count > 1
      }
    }
    return false
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    
    if !isViewLoaded {
      pendingInput = input
      return
    }
    
    inputTextView.string = input.value
    refresh()
  }
  
  func textDidChange(_ notification: Notification) {
    refresh()
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(NSPasteboard.general.string(forType: .string) ?? "")
    refresh()
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {    inputTextView.setStringRetrainUndo("https://www.google.com/search?sxsrf=ALeKk03TpCS68ykjCqWWm7_5xDzmkdCBsw%3A1591797655810&ei=l-fgXsOCMcyl-Qaq8p6AAw&q=sample+long+query+string+url&oq=sample+long+query+string+url&gs_lcp=CgZwc3ktYWIQAzoECAAQRzoCCAA6BggAEBYQHjoICCEQFhAdEB46BAgjECc6BwgAEBQQhwI6BwgjELACECc6BAgAEA06CAgAEAgQDRAeOgoIABAIEA0QChAeUIcLWP4vYIAyaAFwAXgAgAF-iAHQC5IBAzkuNpgBAKABAaoBB2d3cy13aXo&sclient=psy-ab&ved=0ahUKEwiDqtCutPfpAhXMUt4KHSq5BzAQ4dUDCAw&uact=5&bb[]=1&bb[]=ab&&bb[]=x")
    refresh()
  }
  
  @IBAction func settingButtonAction(_ sender: NSButton) {
    if settingViewController == nil {
      settingViewController = QueryStringParserSettingViewController(
        nibName: "QueryStringParserSettingViewController"
      )
    }
    
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  @IBAction func copyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(outputTextView.string, forType: .string)
  }
  
  func refresh() {
    let dict = parseQueryString(inputTextView.string)
    var jsonData: Data?
    
    do {
      if #available(OSX 10.13, *) {
        jsonData = try JSONSerialization.data(withJSONObject: dict, options: [.sortedKeys])
      } else {
        jsonData = try JSONSerialization.data(withJSONObject: dict, options: [])
      }
    } catch {
      log.debug("Cannot serialize to JSON: \(error)")
      return
    }
    
    guard let data = jsonData else {
      outputTextView.string = "JSON Serialization Error"
      return
    }
    
    guard let string = String(data: data, encoding: .utf8) else {
      outputTextView.string = "Encoding Error"
      return
    }
    
    outputTextView.setJSONString(string)
  }
  
  func parseQueryString(_ query: String) -> [String: Any] {
    var queryStrings = [String: Any]()
    
    let urlParts = query.components(separatedBy: "?")
    let qs = urlParts.count > 1 ? urlParts[1] : urlParts[0]
    
    for pair in qs.components(separatedBy: "&") {
      let key = pair.components(separatedBy: "=")[0]
      if key == "" {
        continue
      }
      
      let components = pair.components(separatedBy:"=")
      
      let value = components.count > 1
        ? components[1].decodeUrl() ?? ""
        : ""
      
      if var v = queryStrings[key] as? [String] {
        v.append(value)
        queryStrings[key] = v
      } else if let v = queryStrings[key] as? String {
        queryStrings[key] = [v, value]
      } else {
        queryStrings[key] = value
      }
    }
    return queryStrings
  }
  
  override func ensureDefault(_ forceDefaults: Bool = false) {
    QueryStringParserViewController.ensureDefaults(forceDefaults)
  }

  static func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.query-string-parser-auto-detect-variables", true, forceDefaults)
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("")
    refresh()
  }
}

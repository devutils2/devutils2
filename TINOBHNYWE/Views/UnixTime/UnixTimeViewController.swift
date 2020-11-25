//
//  UnixTimeViewController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/16/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import SwiftDate

let expressionRegex = try! NSRegularExpression(pattern: "^[0-9]+([+\\-*/][0-9]+)*$")

func isUnix(_ input: String, _ startTime: Int, _ endTime: Int) -> Bool {
  let inputInt = Int(input)
  if inputInt == nil {
    return false
  }
  return inputInt! > startTime && inputInt! < endTime
}

func isMillis(_ input: String, _ startTime: Int, _ endTime: Int) -> Bool {
  let inputInt = Int(input)
  if inputInt == nil {
    return false
  }
  return inputInt! > startTime * 1000 && inputInt! < endTime * 1000
}

func isDateString(_ input: String) -> Bool {
  return input.toDate() != nil
}

func isValidExpression(_ str: String) -> Bool {
  let range = NSRange(location: 0, length: str.utf16.count)
  return expressionRegex.firstMatch(in: str, options: [], range: range) != nil
}

func getInputAsInt(_ input: String) -> Int? {
  var timeInt = Int(input)
  if isValidExpression(input.replacingOccurrences(of: " ", with: "")) {
    let exp = NSExpression(format: input)
    timeInt = exp.expressionValue(with: nil, context: nil) as? Int
  }
  return timeInt
}

class UnixTimeViewController: ToolViewController, NSTextFieldDelegate {
  @IBOutlet weak var inputTextField: NSTextField!
  @IBOutlet weak var now: NSButton!
  @IBOutlet weak var relativeTooltip: NSTextField!
  @IBOutlet weak var inputFormat: NSPopUpButton!
  @IBOutlet weak var statusLabel: NSTextField!
  
  @IBOutlet weak var local: OutputTextField!
  @IBOutlet weak var utc: OutputTextField!
  @IBOutlet weak var relative: OutputTextField!
  @IBOutlet weak var dayOfYear: OutputTextField!
  @IBOutlet weak var weekOfYear: OutputTextField!
  @IBOutlet weak var isLeapYear: OutputTextField!
  @IBOutlet weak var unixTime: OutputTextField!
  
  var settingViewController: UnixTimeSettingViewController!

  var timer: Timer!
  
  enum InputFormat {
    case UnixTime
    case MilliSecondsSinceEpoch
    case Auto
  }
  
  var format: InputFormat = .UnixTime
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timer = Timer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(updateRelativeTime),
      userInfo: nil,
      repeats: true
    )
    UnixTimeViewController.ensureDefaults()
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
  }
  
  deinit {
    timer?.invalidate()
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    if !isViewLoaded {
      pendingInput = input
      return
    }
    
    log.debug("UNIX tool activated: \(input)")
    inputTextField.stringValue = input.value.trimmingCharacters(in: .whitespacesAndNewlines)
    
    let startTime = getStartTime()
    let endTime = getEndTime()
    if isUnix(input.value, startTime, endTime) {
      inputFormat.selectItem(at: 0)
      format = .UnixTime
    } else if isMillis(input.value, startTime, endTime) {
      inputFormat.selectItem(at: 1)
      format = .MilliSecondsSinceEpoch
    } else if isDateString(input.value) {
      inputFormat.selectItem(at: 2)
      format = .Auto
    }
    execute()
  }
  
  @objc
  func updateRelativeTime() {
    execute()
  }
  
  
  @IBAction func formatChanged(_ sender: Any) {
    // TODO: properly need a safer check than index
    if inputFormat.indexOfSelectedItem == 0 {
      format = .UnixTime
    } else if inputFormat.indexOfSelectedItem == 1 {
      format = .MilliSecondsSinceEpoch
    } else if inputFormat.indexOfSelectedItem == 2 {
      format = .Auto
    }
    execute()
  }
  
  @IBAction func nowAction(_ sender: Any) {
    if format == .UnixTime {
      inputTextField.stringValue = String(Int(Date.init().timeIntervalSince1970))
    } else if format == .MilliSecondsSinceEpoch {
      inputTextField.stringValue = String(Int(Date.init().timeIntervalSince1970) * 1000)
    } else if format == .Auto {
      inputTextField.stringValue = DateInRegion.init().convertTo(region: .local).toISO()
    } else {
      return
    }
    execute()
  }
  
  @IBAction func readFromClipboardClicked(_ sender: Any) {
    let value = NSPasteboard.general.string(forType: .string)
    let clipboardString = value == nil ? "" : value!
    inputTextField.stringValue = clipboardString
      .trimmingCharacters(in: .whitespacesAndNewlines)
  }
  
  func controlTextDidChange(_ obj: Notification) {
    execute()
  }
  
  // to be called from main app to decide if it should choose this UI as default
  override func matchInput(input: String) -> Bool {
    
    let autoDetectEnabled = (NSUserDefaultsController.shared.value(
      forKeyPath: "values.unix-time-auto-detect-enabled") as? Bool) ?? false
    
    if !autoDetectEnabled {
      return false
    }
    
    let startTime = getStartTime()
    let endTime = getEndTime()
    
    log.debug("startTime \(startTime), endTime \(endTime)")
    
    return isUnix(input, startTime, endTime) || isMillis(input, startTime, endTime) || isDateString(input)
  }
  
  func getStartTime() -> Int {
    return (Int(NSUserDefaultsController.shared.value(
      forKeyPath: "values.unix-auto-detect-start-time") as? String ?? "")) ?? 946684800
  }
  
  func getEndTime() -> Int {
    return (Int(NSUserDefaultsController.shared.value(
      forKeyPath: "values.unix-auto-detect-end-time") as? String ?? "")) ?? 32503593600
  }
  
  func execute() {
    hideMessage()
    
    if inputTextField.stringValue == "" {
      clearOutput()
      return
    }
    
    let input = inputTextField.stringValue
    
    let dateInRegion: DateInRegion
    if format == .UnixTime {
      let timeInt = getInputAsInt(input)
      if timeInt == nil {
        showInvalidInput()
        return
      }
      dateInRegion = DateInRegion.init(seconds: .init(timeInt!), region: .UTC)
    } else if format == .MilliSecondsSinceEpoch {
      let timeInt = getInputAsInt(input)
      if timeInt == nil {
        showInvalidInput()
        return
      }
      dateInRegion = DateInRegion.init(seconds: .init((timeInt! / 1000)), region: .UTC)
    } else if format == .Auto {
      let d = input.toDate()
      if d == nil {
        showInvalidInput()
        return
      }
      dateInRegion = d!
    } else {
      // invalid format type
      return
    }
    
    
    let relativeString = dateInRegion.date.timeAgo()
    utc.setValue(dateInRegion.toISO())
    local.setValue(dateInRegion.convertTo(region: .local).toString())
    relative.setValue(relativeString)
    dayOfYear.setValue(String(dateInRegion.dayOfYear))
    weekOfYear.setValue(String(dateInRegion.weekOfYear))
    isLeapYear.setValue(dateInRegion.isLeapYear ? "true" : "false")
    unixTime.setValue(String(Int(dateInRegion.timeIntervalSince1970)))
    
    // This check relies on the format of the timeAgo extension
    if relativeString.contains("mo") {
      relativeTooltip.isHidden = false
    } else {
      relativeTooltip.isHidden = true
    }
  }
  
  func showInvalidInput() {
    clearOutput()
    showMessage()
  }
  
  func hideMessage() {
    statusLabel.stringValue = ""
    statusLabel.isHidden = true
  }
  
  func showMessage() {
    statusLabel.stringValue = "Invalid input"
    statusLabel.isHidden = false
  }
  
  func clearOutput() {
    utc.setValue("")
    local.setValue("")
    relative.setValue("")
    dayOfYear.setValue("")
    weekOfYear.setValue("")
    isLeapYear.setValue("")
    unixTime.setValue("")
  }
  
  @IBAction func inputSettingButtonAction(_ sender: NSButton) {
    if settingViewController == nil {
      settingViewController = UnixTimeSettingViewController(
        nibName: "UnixTimeSettingViewController"
      )
    }
    
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  override func ensureDefault(_ forceDefaults: Bool = false) {
    UnixTimeViewController.ensureDefaults(forceDefaults)
  }
  
  static func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.unix-time-auto-detect-enabled", true, forceDefaults)
    AppState.ensureDefault("values.unix-auto-detect-start-time", "946684799", forceDefaults)
    AppState.ensureDefault("values.unix-auto-detect-end-time", "32503593600", forceDefaults)
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextField.stringValue = ""
    execute()
  }
}

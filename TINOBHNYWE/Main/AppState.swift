//
//  AppState.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/16/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import ShortcutRecorder

let DEFAULT_GLOBAL_HOTKEY = Shortcut.init(keyEquivalent: "⌃⌥⌘Space")! // Ctrl + Option + Command + Space

class ActivationValue: CustomStringConvertible {
  enum Source {
    case clipboard
    case service
    case manual
  }
  
  let value: String
  let source: Source
  var description: String {
    return "(\(source)): \(value)"
  }
  
  init(value: String, source: Source) {
    self.value = value
    self.source = source
  }
}

class AppState {
  static let TEXTVIEW_MONO_FONT = "Menlo"
  
  static var UnixTimeTool = Tool.init(
    id: "unixtime",
    name: "Unix Time Converter",
    image: NSImage(named: "clock.fill")!,
    viewControllerType: UnixTimeViewController.self
  )
  static var JSONFormatterTool = Tool.init(
    id: "jsonformatter",
    name: "JSON Formatter/Validator",
    image: NSImage(named: "jsonformatter")!,
    viewControllerType: JSONFormatterViewController.self
  )
  static var JWTTool = Tool.init(
    id: "jwt",
    name: "JWT Debugger",
    image: NSImage(named: "jwt")!,
    viewControllerType: JWTViewController.self
  )
  static var QueryStringParserTool = Tool.init(
    id: "querystringparser",
    name: "Query String Parser",
    image: NSImage(named: "querystring")!,
    viewControllerType: QueryStringParserViewController.self
  )
  static var HTMLEncodeTool = Tool.init(
    id: "htmlencode",
    name: "HTML Entity Encoder/Decoder",
    image: NSImage(named: "htmlentities")!,
    viewControllerType: SharedEndecodeViewController.self,
    implementation: HTMLEntityEndecodeTool.self,
    settingViewControllerType: HTMLEntitySettingViewController.self
  )
  static var Base64EncodeTool = Tool.init(
    id: "base64encode",
    name: "Base64 Encoder/Decoder",
    image: NSImage(named: "base64")!,
    viewControllerType: SharedEndecodeViewController.self,
    implementation: Base64EndecodeTool.self,
    settingViewControllerType: Base64SettingViewController.self
  )
  static var URLEncodeTool = Tool.init(
    id: "urlencode",
    name: "URL Encoder/Decoder",
    image: NSImage(named: "percent")!,
    viewControllerType: SharedEndecodeViewController.self,
    implementation: URLEndecodeTool.self,
    settingViewControllerType: URLEncodeSettingViewController.self
  )
  static var BackslashTool = Tool.init(
    id: "backslash",
    name: "Backslash Escaper/Unescaper",
    image: NSImage(named: "backslash")!,
    viewControllerType: SharedEndecodeViewController.self,
    implementation: BackslashEscapeTool.self,
    settingViewControllerType: BackslashEscapeSettingViewController.self
  )
  
  static var UUIDTool = Tool.init(
    id: "uuidtool",
    name: "UUID Generator/Decoder",
    image: NSImage(named: "uuid")!,
    viewControllerType: UUIDToolViewController.self
  )
  
  static var HTMLPreviewTool = Tool.init(
    id: "htmlpreview",
    name: "HTML Preview",
    image: NSImage(named: "htmltag")!,
    viewControllerType: HTMLPreviewViewController.self
  )
  
  static var TextDiffTool = Tool.init(
    id: "textdiff",
    name: "Text Diff Checker",
    image: NSImage(named: "textdiff")!,
    viewControllerType: TextDiffViewController.self
  )
  
  static var HTMLBeautifierTool = Tool.init(
    id: "htmlformatter",
    name: "HTML Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: HTMLFormatterTool.self
  )
  
  static var CSSBeautifierTool = Tool.init(
    id: "cssformatter",
    name: "CSS Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: CSSFormatterTool.self
  )
  
  static var LESSBeautifierTool = Tool.init(
    id: "lessformatter",
    name: "LESS Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: LESSFormatterTool.self
  )
  
  static var SCSSBeautifierTool = Tool.init(
    id: "scssformatter",
    name: "SCSS Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: SCSSFormatterTool.self
  )
  
  static var JSBeautifierTool = Tool.init(
    id: "jsformatter",
    name: "JS Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: JSFormatterTool.self
  )
  
  static var XMLBeautifierTool = Tool.init(
    id: "xmlformatter",
    name: "XML Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: XMLFormatterTool.self
  )
  
  static var ERBBeautifierTool = Tool.init(
    id: "erbformatter",
    name: "ERB (Ruby) Beautifier/Minifier",
    image: NSImage(named: "magic")!,
    viewControllerType: SharedFormatterViewController.self,
    implementation: ERBFormatterTool.self
  )
  
  static var tools: [Tool] = [
    UnixTimeTool,
    URLEncodeTool,
    JSONFormatterTool,
    JWTTool,
    Base64EncodeTool,
    QueryStringParserTool,
    HTMLEncodeTool,
    BackslashTool,
    UUIDTool,
    HTMLPreviewTool,
    TextDiffTool,
    HTMLBeautifierTool,
    CSSBeautifierTool,
    JSBeautifierTool,
    //    ERBBeautifierTool,
    //    LESSBeautifierTool,
    //    SCSSBeautifierTool
    XMLBeautifierTool
  ]

  static func shouldShowDockIcon() -> Bool {
    return UserDefaults.standard.value(forKey: "show-dock-icon") as? Bool ?? true
  }
  
  static func shouldShowStatusIcon() -> Bool {
    return UserDefaults.standard.value(forKey: "show-status-icon") as? Bool ?? true
  }

  static func setLaunchAtLogin(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "launch-at-login")
  }
  
  static func getLaunchAtLogin() -> Bool {
     return UserDefaults.standard.value(forKey: "launch-at-login") as? Bool ?? false
  }
  
  static func setDockIconPreference(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "show-dock-icon")
  }
  
  static func setStatusIconPreference(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "show-status-icon")
  }
  
  static func getWriteDebugLog() -> Bool {
    return UserDefaults.standard.value(forKey: "write-debug-logs") as? Bool ?? false
  }
  
  static func setWriteDebugLog(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "write-debug-logs")
  }
  
  static func getToolsSortOrder() -> String {
    return UserDefaults.standard.value(forKey: "tools-sort-order") as? String ?? "default"
  }
  
  static func setToolsSortOrder(_ value: String) {
    UserDefaults.standard.set(value, forKey: "tools-sort-order")
  }
  
  static func getGlobalHotkeyPreference() -> Shortcut {
    if let dictionary = UserDefaults.standard.value(forKey: "global-hotkey") as? [AnyHashable : Any] {
      return Shortcut.init(dictionary: dictionary) ?? DEFAULT_GLOBAL_HOTKEY
    }
    return DEFAULT_GLOBAL_HOTKEY
  }
  
  static func setGlobalHotkeyPreference(_ shortcut: Shortcut) {
    UserDefaults.standard.set(shortcut.dictionaryRepresentation, forKey: "global-hotkey")
  }
  
  static func getAppVersion() -> String {
    let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    let versionNumber = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
    if let versionNumber = versionNumber, let buildNumber = buildNumber {
      return "\(versionNumber) (\(buildNumber))"
    } else if let versionNumber = versionNumber {
      return versionNumber
    } else if let buildNumber = buildNumber {
      return buildNumber
    } else {
      return ""
    }
  }
  
  static func ensureDefaultsForAutoDetect() {
    ensureDefault("values.auto-use-clipboard-content-when-activate", true, false)
    ensureDefault("values.auto-clipboard-global-hotkey", true, false)
    ensureDefault("values.auto-clipboard-status-bar-icon", true, false)
  }
  
  static func getAutoClipboardGlobalHotKey() -> Bool {
    return NSUserDefaultsController.shared.value(
      forKeyPath: "values.auto-clipboard-global-hotkey") as? Bool ?? true
  }
  
  static func getAutoClipboardStatusBarIcon() -> Bool {
    return NSUserDefaultsController.shared.value(
      forKeyPath: "values.auto-clipboard-status-bar-icon") as? Bool ?? true
  }
  
  static func setAutomaticClipboard(_ value: Bool) {
    UserDefaults.standard.set(value, forKey: "automatic-clipboard")
  }
  
  static func getAutomaticClipboard() -> Bool {
    return UserDefaults.standard.value(forKey: "automatic-clipboard") as? Bool ?? true
  }
  
  static func ensureDefault(_ keyPath: String, _ defaultValue: Bool, _ force: Bool) {
    let value = NSUserDefaultsController.shared.value(
      forKeyPath: keyPath) as? Bool
    
    if value == nil || force {
      NSUserDefaultsController.shared.setValue(
        defaultValue, forKeyPath: keyPath)
    }
  }
  
  static func ensureDefault(_ keyPath: String, _ defaultValue: Int, _ force: Bool) {
    let value = NSUserDefaultsController.shared.value(
      forKeyPath: keyPath) as? Int
    
    if value == nil || force {
      NSUserDefaultsController.shared.setValue(
        defaultValue, forKeyPath: keyPath)
    }
  }
  
  static func ensureDefault(_ keyPath: String, _ defaultValue: String, _ force: Bool) {
    let value = NSUserDefaultsController.shared.value(
      forKeyPath: keyPath) as? String
    
    if value == nil || force {
      NSUserDefaultsController.shared.setValue(
        defaultValue, forKeyPath: keyPath)
    }
  }
  
  static func isSandboxed() -> Bool {
      let environ = ProcessInfo.processInfo.environment
      return (nil != environ["APP_SANDBOX_CONTAINER_ID"])
  }
  
  static func getOrderedNames() -> [String]? {
    return UserDefaults.standard.value(forKey: "custom-tools-ordered-names") as? [String]
  }
  
  static func setOrderedNames(_ value: [String]) {
    UserDefaults.standard.set(value, forKey: "custom-tools-ordered-names")
  }
  
}

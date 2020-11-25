//
//  AppDelegate.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 4/2/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import HotKey
import ShortcutRecorder
import ServiceManagement
import SwiftyBeaver
import JavaScriptCore

let log = SwiftyBeaver.self

extension Notification.Name {
  static let killLauncher = Notification.Name("killLauncher")
}

enum ActivateSource {
  case GlobalHotkey
  case StatusBar
  case Service
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  var timer: Timer?
  var hotKey: HotKey!
  var myWindowController: WindowController!
  var preferenceWindowController: NSWindowController!
  let statusItem = NSStatusBar.system.statusItem(withLength: NSStatusItem.squareLength)
  var manualLaunch: Bool = true
  let launcherAppId = "tonyapp.devutils2.launcher"
  @IBOutlet weak var toolsSortOrderDefaultMenuItem: NSMenuItem!
  @IBOutlet weak var toolsSortOrderAlphabetMenuItem: NSMenuItem!
  @IBOutlet weak var toolsSortOrderCustomMenuItem: NSMenuItem!
  
  func testMe() {
    // Test
  }

  struct NotificationNames {
    static let AppActivated = Notification.Name("AppActivatedNotification")
    static let AppToolsOrderChanged = Notification.Name("AppToolsOrderChanged")
  }
  
  func disableSparkleUpdate() {
    let mainMenu = NSApp.mainMenu!
    let appMenu = mainMenu.item(at: 0)!.submenu
    let checkUpdateItem = appMenu?.item(withTitle: "Check for Updates...")
    checkUpdateItem?.isHidden = true
  }
  

  func setUpSandboxed() {
    log.info("App sandbox: \(AppState.isSandboxed())")
    
    if !AppState.isSandboxed() {
      return;
    }
    
    disableSparkleUpdate()
  }
  
  @IBAction func preferenceMenuAction(_ sender: Any) {
    openPreferenceWindow()
  }
  
  // Call this method when you need to remove all UserDefaults values
  func resetAllDefaults() {
    let domain = Bundle.main.bundleIdentifier!
    UserDefaults.standard.removePersistentDomain(forName: domain)
    UserDefaults.standard.synchronize()
  }
  
  func setupLogging() {
    let console = ConsoleDestination()  // log to Xcode Console
    let file = FileDestination()  // log to default swiftybeaver.log file

    console.format = "$Dyyyy-MM-dd HH:mm:ss.SSS$d $C$L$c $N.$F:$l - $M"
    file.format = "$J" // JSON

    // add the destinations to SwiftyBeaver
    log.addDestination(console)
    
    if (AppState.getWriteDebugLog()) {
      log.addDestination(file)
      log.info("Debug log is enabled, log file is at: \(file.logFileURL?.absoluteString ?? "(empty)")")
    }
    log.info("App version: \(AppState.getAppVersion())")
  }

  func applicationDidFinishLaunching(_ aNotification: Notification) {
    // resetAllDefaults()
    
    // Check if this is a manual launch or a launch by launcher (login item)
    // This check rely on an undocumented behavior of MacOS that a random
    // paramater will be passed if the app is launched by our launcher.
    // Note that our app is sandboxed so we can't use this arguments correctly.
    manualLaunch = ProcessInfo.processInfo.arguments.count == 1

    setupLogging()
    setupAppWindow()
    setupHotkey()
    setupStatusIcon()
    setUpSandboxed()
    refreshAppIconsStatus()
    setupObservers()
    killLauncherApp()
    setToolOrderMenuState()
    
    NSApp.servicesProvider = self
    
    ValueTransformer.setValueTransformer(
      UnixTimeToISOString(), forName: .init("UnixTimeToISOString"))
    
    AppState.ensureDefaultsForAutoDetect()
    testMe()
  }
  
  @IBAction func newMenuItemAction(_ sender: Any) {
    self.myWindowController.showWindow(self)
  }
  
  func applicationShouldHandleReopen(_ sender: NSApplication, hasVisibleWindows flag: Bool) -> Bool {
    openAppWindow()
    return true
  }

  let errorMessage = NSString(string: "Could not find the text for parsing.")

  @objc func serviceHandler(
    _ pasteboard: NSPasteboard,
    userData: String?,
    error: AutoreleasingUnsafeMutablePointer<NSString>) {
    log.debug("Service Received")
    
    guard let str = pasteboard.string(forType: .string) else {
      error.pointee = errorMessage
      log.debug("No string provided by service. Cancel.")
      return
    }
    
    self.openAppWindow()
    self.notifyAppActivation(str, .Service)
  }
  
  func setupObservers() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(userDefaultsChanged),
      name: PreferencesViewController.NotificationNames.userDefaultsChanged,
      object: nil)
  }
  
  @objc
  func userDefaultsChanged() {
    refreshAppIconsStatus()
    setupHotkey()
    setupLaunchAtLogin()
  }
  
  func setupLaunchAtLogin() {
    if !SMLoginItemSetEnabled(launcherAppId as CFString, AppState.getLaunchAtLogin()) {
      let alert = NSAlert()
      alert.messageText = "Hm... Something's wrong"
      alert.informativeText = "Tried to change launch app at login setting but unable to do so because something is broken. Please contact developer, thank you very much!"
      alert.alertStyle = .warning
      alert.addButton(withTitle: "OK")
      alert.runModal()
    }
  }
  
  func openPreferenceWindow() {
    if preferenceWindowController == nil {
      self.preferenceWindowController = NSStoryboard(name: "Preferences", bundle: nil)
        .instantiateInitialController() as? NSWindowController
    }
    self.myWindowController.window?.addChildWindow((self.preferenceWindowController?.window)!, ordered: .above)
    self.preferenceWindowController.showWindow(self)
  }
  
  func setupAppWindow() {
    self.myWindowController = NSStoryboard(name: "Main", bundle: nil)
      .instantiateController(withIdentifier: "MainWindow") as? WindowController

    if manualLaunch {
      self.myWindowController.showWindow(self)
    } else {
      self.myWindowController.close()
    }
  }
  
  func setupHotkey() {
    let shortcut = AppState.getGlobalHotkeyPreference()
    
    // Unregister previous hotkey if any
    if hotKey != nil {
      hotKey.isPaused = true
    }
    
    hotKey = HotKey.init(
      carbonKeyCode: shortcut.carbonKeyCode,
      carbonModifiers: shortcut.carbonModifierFlags
    )
    
    hotKey.keyDownHandler = {
      log.debug("Hotkey activated")
      if self.myWindowController.window?.isMainWindow ?? false {
        log.debug("Current window is having focus. Closing.")
        self.closeAppWindow()
      } else {
        log.debug("Refocus the existing window or open new window and activate app")
        let visible = self.myWindowController.window?.isVisible ?? false
        self.openAppWindow()
        
        if !visible {
          self.notifyAppActivation(nil, .GlobalHotkey)
        } else {
          log.debug("App not activated because window is open")
        }
      }
    }
  }
  
  func setupStatusIcon() {
    let icon = NSImage(named: "MenuIcon")
    icon?.isTemplate = true // best for dark mode
    statusItem.button!.imageScaling = .scaleProportionallyDown
    statusItem.button!.image = icon
    statusItem.button!.action = #selector(self.statusItemClick(sender:))
  }
  
  func refreshAppIconsStatus() {
    if #available(OSX 10.12, *) {
      statusItem.isVisible = AppState.shouldShowStatusIcon()
    } else {
      // Fallback on earlier versions
      statusItem.button?.isHidden = !AppState.shouldShowStatusIcon()
      statusItem.length = AppState.shouldShowStatusIcon() ? NSStatusItem.squareLength : 0
    }

    // Always debounce NSApp.setActivationPolicy calls as it may create
    // multiple unwanted dock icons.
    timer?.invalidate()
    
    timer = Timer.scheduledTimer(
      timeInterval: 0.3,
      target: self,
      selector: #selector(executeAppDockChange), userInfo: nil,
      repeats: false)
  }
  
  @objc
  func executeAppDockChange() {
    // Set the initial dock icon
    if AppState.shouldShowDockIcon() {
      NSApp.setActivationPolicy(.regular)
    } else {
      // This precheck is to ensure we only switch the activation policy
      // to .accessory only when needed, as it causes the window to be closed
      // and repopened every time user changes the setting.
      if NSApp.activationPolicy() != .accessory {
        NSApp.setActivationPolicy(.accessory)
        DispatchQueue.main.async {
          NSApplication.shared.activate(ignoringOtherApps: true)
          NSApplication.shared.windows.first!.makeKeyAndOrderFront(self)
        }
      }
    }
  }
  
  func openAppWindow() {
    self.myWindowController.showWindow(self)
    NSApp.activate(ignoringOtherApps: true)
  }
  
  func closeAppWindow() {
    self.myWindowController.close()
    if self.preferenceWindowController != nil {
      self.preferenceWindowController.close()
    }
  }
  
  @objc func statusItemClick(sender: NSStatusItem) {
    log.debug("statusItemClick")
    let visible = myWindowController.window?.isVisible ?? false
    openAppWindow()
    
    if !visible {
      notifyAppActivation(nil, .StatusBar)
    } else {
      log.debug("App not activated because window is open")
    }
  }
  
  func notifyAppActivation(_ str: String?, _ activateSource: ActivateSource) {
    var value: ActivationValue? = nil
    
    if str != nil {
      log.debug("App activated with string. Source: \(activateSource). String: \(str ?? "")")
      value = ActivationValue.init(value: str!, source: .service)
    } else if AppState.getAutomaticClipboard() {
      if (
          (AppState.getAutoClipboardGlobalHotKey() && activateSource == .GlobalHotkey) ||
          (AppState.getAutoClipboardStatusBarIcon() && activateSource == .StatusBar)
        ) {
        let clipboardString = NSPasteboard.general.string(forType: .string) ?? ""
        log.debug("App activated with clipboard. Source: \(activateSource). Clipboard: \(clipboardString)")
        value = ActivationValue.init(value: clipboardString, source: .clipboard)
      } else {
        log.debug("App activated with no string. Source: \(activateSource)")
      }
    }
    
    NotificationCenter.default.post(
      name: AppDelegate.NotificationNames.AppActivated,
      object: value
    )
  }
  
  func killLauncherApp() {
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = !runningApps.filter {
      $0.bundleIdentifier == launcherAppId
    }.isEmpty

    if isRunning {
        DistributedNotificationCenter.default()
          .post(name: .killLauncher, object: Bundle.main.bundleIdentifier!)
    }
  }
  
  @IBAction func toolsSortOrderDefaultAction(_ sender: Any) {
    setAllOrderMenuToOff()
    toolsSortOrderDefaultMenuItem.state = .on
    AppState.setToolsSortOrder("default")
    
    NotificationCenter.default.post(
      name: AppDelegate.NotificationNames.AppToolsOrderChanged,
      object: nil
    )
  }
  
  @IBAction func toolsSortOrderAlphabetAction(_ sender: Any) {
    setAllOrderMenuToOff()
    toolsSortOrderAlphabetMenuItem.state = .on
    AppState.setToolsSortOrder("alphabet")
    
    NotificationCenter.default.post(
      name: AppDelegate.NotificationNames.AppToolsOrderChanged,
      object: nil
    )
  }
  
  @IBAction func toolsSortOrderCustomAction(_ sender: Any) {
    setAllOrderMenuToOff()
    toolsSortOrderCustomMenuItem.state = .on
    AppState.setToolsSortOrder("custom")
    
    NotificationCenter.default.post(
      name: AppDelegate.NotificationNames.AppToolsOrderChanged,
      object: nil
    )
  }
  
  func setAllOrderMenuToOff() {
    toolsSortOrderDefaultMenuItem.state = .off
    toolsSortOrderAlphabetMenuItem.state = .off
    toolsSortOrderCustomMenuItem.state = .off
  }

  func setToolOrderMenuState() {
    toolsSortOrderDefaultMenuItem.state = .off
    toolsSortOrderAlphabetMenuItem.state = .off
    if AppState.getToolsSortOrder() == "alphabet" {
      toolsSortOrderAlphabetMenuItem.state = .on
    } else if AppState.getToolsSortOrder() == "custom" {
      toolsSortOrderCustomMenuItem.state = .on
    } else {
      toolsSortOrderDefaultMenuItem.state = .on
    }
  }
  
}


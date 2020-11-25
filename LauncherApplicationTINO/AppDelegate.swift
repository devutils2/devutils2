//
//  AppDelegate.swift
//  LauncherApplicationTINO
//
//  Created by Tony Dinh on 5/20/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

extension Notification.Name {
  static let killLauncher = Notification.Name("killLauncher")
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
  func applicationDidFinishLaunching(_ aNotification: Notification) {
    let mainAppIdentifier = "tonyapp.devutils2"
    let runningApps = NSWorkspace.shared.runningApplications
    let isRunning = !runningApps.filter {
      $0.bundleIdentifier == mainAppIdentifier
    }.isEmpty
    
    if !isRunning {
      DistributedNotificationCenter.default().addObserver(
        self,
        selector: #selector(self.terminate),
        name: .killLauncher,
        object: mainAppIdentifier)
      
      let path = Bundle.main.bundlePath as NSString
      var components = path.pathComponents
      components.removeLast()
      components.removeLast()
      components.removeLast()
      components.append("MacOS")
      components.append("DevUtils2") //main app name
      
      let newPath = NSString.path(withComponents: components)
      try! NSWorkspace.shared.launchApplication(at: .init(fileURLWithPath: newPath), options: .andHide, configuration: [NSWorkspace.LaunchConfigurationKey.arguments:"laucher"])
    }
    else {
      self.terminate()
    }
  }
  
  @objc func terminate() {
    NSApp.terminate(nil)
  }
}


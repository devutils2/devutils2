//
//  NSView.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/18/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

extension NSView {
  func fillParent(parent: NSView) {
    NSLayoutConstraint.activate(
      [
        self.topAnchor.constraint(equalTo: parent.topAnchor),
        self.bottomAnchor.constraint(equalTo: parent.bottomAnchor),
        self.leftAnchor.constraint(equalTo: parent.leftAnchor),
        self.rightAnchor.constraint(equalTo: parent.rightAnchor),
      ]
    )
  }
  
  var hasDarkAppearance: Bool {
    guard let style = UserDefaults.standard.string(forKey: "AppleInterfaceStyle") else {
      return false
    }
    return style == "Dark"
    
    // Second method
//    if #available(OSX 10.14, *) {
//      switch effectiveAppearance.name {
//      case .darkAqua,
//           .vibrantDark,
//           .accessibilityHighContrastDarkAqua,
//           .accessibilityHighContrastVibrantDark:
//        return true
//      default:
//        return false
//      }
//    } else {
//      switch effectiveAppearance.name {
//      case .vibrantDark:
//        return true
//      default:
//        return false
//      }
//    }
  }
}

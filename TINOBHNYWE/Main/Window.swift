//
//  Window.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/4/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class Window: NSWindow {
  override func mouseUp(with event: NSEvent) {
      if event.clickCount >= 2 && isPointInTitleBar(point: event.locationInWindow) { // double-click in title bar
          self.performZoom(nil)
      }
      super.mouseUp(with: event)
  }

  fileprivate func isPointInTitleBar(point: CGPoint) -> Bool {
      if let windowFrame = self.contentView?.frame {
          let titleBarRect = NSRect(x: self.contentLayoutRect.origin.x, y: self.contentLayoutRect.origin.y+self.contentLayoutRect.height, width: self.contentLayoutRect.width, height: windowFrame.height-self.contentLayoutRect.height)
          return titleBarRect.contains(point)
      }
      return false
  }
}

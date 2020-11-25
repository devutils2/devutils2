//
//  WrapableTextView.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/11/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class WrapableTextView: NSTextView {
  var wordwrap: Bool = true

  required init?(coder: NSCoder) {
    super.init(coder: coder)
    
    let menuTitle = "Toggle line wrap"
    // Notice: The menu is shared accross all NSTextView instances, so we need
    // to make a copy here
    let menuCopy = self.menu!.copy() as! NSMenu
    self.menu = menuCopy
    var woldwrapMenuItem = menu?.item(withTitle: menuTitle)
    
    if woldwrapMenuItem == nil {
      woldwrapMenuItem = menu?.insertItem(
        withTitle: menuTitle,
        action: #selector(toggleLineWrap),
        keyEquivalent: "",
        at: 0
      )
    }
  }
  
  func setWordwrap(_ wordwrap: Bool) {
    self.wordwrap = wordwrap
    updateWordWrap()
  }
  
  func updateWordWrap() {
    let scrollView = self.enclosingScrollView!
    self.minSize = CGSize(width: 0, height: 0)
    self.maxSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)

    if self.wordwrap {
      let sz1 = scrollView.contentSize
      self.textContainer!.containerSize = CGSize(width: sz1.width, height: CGFloat.greatestFiniteMagnitude)
      self.textContainer!.widthTracksTextView = true
      // self.frame must be set after self.textContainer!.containerSize, otherwise layout won't be updated sometime
      self.frame = CGRect(x: 0, y: 0, width: sz1.width, height: 0)
      self.isHorizontallyResizable = false
      scrollView.hasHorizontalScroller = false
    } else {
      self.textContainer!.widthTracksTextView = false
      self.textContainer!.containerSize = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
      self.isHorizontallyResizable = true
      scrollView.hasHorizontalScroller = true
    }
  }

  @objc
  func toggleLineWrap() {
    self.wordwrap = !self.wordwrap
    updateWordWrap()
  }
}

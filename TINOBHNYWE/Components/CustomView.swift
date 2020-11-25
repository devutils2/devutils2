//
//  CustomView.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/18/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class CustomView: NSView {
  @IBOutlet var contentView: NSView!
  
  override init(frame frameRect: NSRect) {
    super.init(frame: frameRect)
    setup()
  }
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    setup()
  }
  
  private func setup() {
    self.translatesAutoresizingMaskIntoConstraints = false
    
    let bundle = Bundle(for: type(of: self))
    let nib = NSNib(nibNamed: .init(String(describing: type(of: self))), bundle: bundle)!
    nib.instantiate(withOwner: self, topLevelObjects: nil)
    
    addSubview(contentView)
    
    self.contentView.translatesAutoresizingMaskIntoConstraints = false
    contentView.fillParent(parent: self)
  }
}

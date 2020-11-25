//
//  NSTextView.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/25/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

extension NSTextView {
  func setMonoFont() {
    if let menlo = NSFont(name: AppState.TEXTVIEW_MONO_FONT, size: 12) {
      self.typingAttributes = [
        NSAttributedString.Key.font: menlo,
        NSAttributedString.Key.foregroundColor: NSColor.textColor
      ]
    }
  }
  
  func nicePadding() {
    self.textContainerInset = .init(width: 3, height: 8)
  }
  
  func setupStandardTextview() {
    self.setMonoFont()
    self.nicePadding()
    self.usesFindBar = true
    self.isAutomaticQuoteSubstitutionEnabled = false
    self.isAutomaticDataDetectionEnabled = false
    self.isAutomaticLinkDetectionEnabled = false
    self.isAutomaticTextReplacementEnabled = false
    self.isAutomaticDashSubstitutionEnabled = false
    self.isAutomaticSpellingCorrectionEnabled = false
    self.allowsUndo = true
  }
  
  func setStringRetrainUndo(_ value: String) {
    self.selectAll(self)
    self.insertText(
      value,
      replacementRange: .init(location: 0, length: self.textStorage?.length ?? 0)
    )
  }
  
  func copyToClipboardFormatted() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.declareTypes([.string], owner: self)
    NSPasteboard.general.writeObjects([self.attributedString()])
  }
  
  func copyToClipboard() {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(self.string, forType: .string)
  }
}

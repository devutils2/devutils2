//
//  HotkeyRecorder.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/19/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import ShortcutRecorder

protocol HotkeyRecorderDelegate {
  func hotKeyRecorderDidEndRecording(shortcut: Shortcut)
  func hotKeyRecorderDidCancelRecording()
  func hotKeyRecorderValidationFailed(message: String)
}

class HotkeyRecorder: CustomView, RecorderControlDelegate {
  var recorder: RecorderControl!
  var delegate: HotkeyRecorderDelegate?
  
  required init?(coder decoder: NSCoder) {
    super.init(coder: decoder)
    recorder = RecorderControl()
    recorder.translatesAutoresizingMaskIntoConstraints = false
    self.addSubview(recorder)
    recorder.fillParent(parent: self)
    recorder.delegate = self
  }
  
  func setValue(_ shortcut: Shortcut) {
    recorder.objectValue = shortcut
  }
  
  func setCombo(_ combo: String) {
    recorder.objectValue = Shortcut.init(keyEquivalent: combo)
  }
  
  func recorderControlDidEndRecording(_ aControl: RecorderControl) {
    if let shortcut = aControl.objectValue {
      let validator = ShortcutValidator()
      do {
        try validator.validate(shortcut: shortcut)
        delegate?.hotKeyRecorderDidEndRecording(shortcut: shortcut)
      }
      catch let error as NSError {
        delegate?.hotKeyRecorderValidationFailed(
          message: error.localizedDescription)
      }
    } else {
      delegate?.hotKeyRecorderDidCancelRecording()
    }
  }
}

//
//  SharedEndecodeViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 6/13/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class SharedEndecodeViewController: ToolViewController, NSTextViewDelegate, ToolSettingDelegate {
  @IBOutlet var inputTextView: NSTextView!
  @IBOutlet var outputTextView: NSTextView!
  @IBOutlet weak var encodeButton: NSButton!
  @IBOutlet weak var decodeButton: NSButton!
  @IBOutlet weak var sampleButton: NSButton!
  @IBOutlet weak var settingButton: NSButton!
  
  var endecodeTool: EndecodeTool!
  var settingViewController: ToolSettingViewController?
  var options: ToolOptions?
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  required init(nibName: NSNib.Name?) {
    super.init(nibName: nibName)
  }
  
  required init(endecodeTool: EndecodeTool, settingViewController: ToolSettingViewController?) {
    self.endecodeTool = endecodeTool
    self.settingViewController = settingViewController
    self.settingViewController?.ensureDefaults()
    self.options = settingViewController?.getOptions()
    log.debug("SharedEndecodeViewController.init: \(endecodeTool), \(settingViewController)")
    super.init(nibName: "SharedEndecodeViewController")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    log.debug("viewDidLoad: \(String(describing: endecodeTool))")
    inputTextView.setupStandardTextview()
    outputTextView.setupStandardTextview()
    
    self.settingViewController?.delegate = self
    if self.endecodeTool.getSampleString() != nil {
      sampleButton.isHidden = false
    }
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
    
    encodeButton.title = endecodeTool.getEncodeLabel()
    decodeButton.title = endecodeTool.getDecodeLabel()
    
    if !endecodeTool.hasSetting() {
      settingButton.isHidden = true
    }
  }
  
  override func matchInput(input: String) -> Bool {
    if input.count == 0 {
      return false
    }
    
    guard let ops = options else {
      log.debug("No options set!")
      return false
    }
    
    if !ops.autoDetect {
      return false
    }
    
    do {
      return try endecodeTool.decode(input, ops) != input
    } catch {
      log.debug("matchInput failed: \(error)")
      return false
    }
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    
    if !isViewLoaded {
      pendingInput = input
      log.debug("input queued")
      return
    }
    
    log.debug("activate: \(String(describing: endecodeTool)): \(input.value)")
    inputTextView.string = input.value
    
    guard let ops = options else {
      log.debug("No options set!")
      return
    }

    // Automatic select decode if input is decodeable
    do {
      let decoded = try endecodeTool.decode(input.value, ops)
      if decoded != input.value {
        decodeButton.objectValue = true
        encodeButton.objectValue = false
      }
      
      refresh()
    } catch {
      log.debug("Failed: \(error)")
    }
  }
  
  func textDidChange(_ notification: Notification) {
    refresh()
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(NSPasteboard.general.string(forType: .string) ?? "")
  }
  
  @IBAction func settingButtonAction(_ sender: NSButton) {
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  @IBAction func encodeButtonAction(_ sender: Any) {
    decodeButton.objectValue = false
    refresh()
  }
  
  @IBAction func decodeButtonAction(_ sender: Any) {
    encodeButton.objectValue = false
    refresh()
  }
  
  @IBAction func outputCopyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(outputTextView.string, forType: .string)
  }
  
  @IBAction func useAsInputButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(outputTextView.string)
  }
  
  func refresh() {
    guard let ops = options else {
      log.debug("No options set!")
      return
    }
    
    if decodeButton.objectValue as? Bool == true {
      do {
        let decoded = try endecodeTool.decode(inputTextView.string, ops)
        outputTextView.textColor = .textColor
        outputTextView.string = decoded
      } catch {
        outputTextView.string = "Error: \(error)"
        outputTextView.textColor = .red
      }
    }
    
    if encodeButton.objectValue as? Bool == true {
      do {
        let encoded = try endecodeTool.encode(inputTextView.string, ops)
        outputTextView.textColor = .textColor
        outputTextView.string = encoded
      } catch {
        outputTextView.string = "Error: \(error)"
        outputTextView.textColor = .red
      }
    }
  }
  
  func onOptionsChanged(options: ToolOptions) {
    log.debug("options changed: \(options.debugDescription())")
    self.options = options
    refresh()
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(self.endecodeTool.getSampleString() ?? "")
    if endecodeTool.isSampleNeedEncode() {
      decodeButton.objectValue = false
      encodeButton.objectValue = true
    } else {
      decodeButton.objectValue = true
      encodeButton.objectValue = false
    }
    refresh()
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("")
    refresh()
  }
}

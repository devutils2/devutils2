//
//  SharedBeautifierMinifierViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/12/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class SharedFormatterViewController: ToolViewController, NSTextViewDelegate {
  @IBOutlet var inputTextView: NSTextView!
  @IBOutlet var outputTextView: HighlightedTextView!
  @IBOutlet weak var sampleButton: NSButton!
  
  var formatterTool: FormatterTool!
  var options: FormatToolOptions = .init(formatMode: .twoSpaces)
  
  required init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  required init(nibName: NSNib.Name?) {
    super.init(nibName: nibName)
  }
  
  required init(formatterTool: FormatterTool, settingViewController: ToolSettingViewController?) {
    self.formatterTool = formatterTool
    log.debug("SharedFormatterViewController.init: \(formatterTool)")
    super.init(nibName: "SharedFormatterViewController")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    inputTextView.setupStandardTextview()
    outputTextView.setupStandardTextview()
    if let language = formatterTool.getHighlighterLanguage() {
      outputTextView.setLanguage(language: language)
    }
    
    if self.formatterTool.getSampleString() != nil {
      sampleButton.isHidden = false
    }
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
    
  }
  
  func textDidChange(_ notification: Notification) {
    refresh()
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    
    if !isViewLoaded {
      pendingInput = input
      log.debug("input queued")
      return
    }
    
    log.debug("activate: \(String(describing: formatterTool)): \(input.value)")
    inputTextView.string = input.value

    refresh()
  }
  
  @IBAction func loadFileButtonAction(_ sender: Any) {
    if let fileContent = GeneralHelpers.loadFileAsUTF8(title: "Select a file") {
      inputTextView.string = fileContent
      refresh()
    }
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo(NSPasteboard.general.string(forType: .string) ?? "")
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("")
    refresh()
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {
    if let sample = self.formatterTool.getSampleString() {
      inputTextView.setStringRetrainUndo(sample)
      refresh()
    }
  }
  
  @IBAction func formatDropdownButtonAction(_ sender: NSPopUpButton) {
    if sender.selectedItem?.title == "2 spaces" {
      options.formatMode = .twoSpaces
    } else if sender.selectedItem?.title == "4 spaces" {
      options.formatMode = .fourSpaces
    } else if sender.selectedItem?.title == "1 tab" {
      options.formatMode = .oneTab
    } else if sender.selectedItem?.title == "Minified" {
      options.formatMode = .minified
    } else {
      log.error("inconsistent popup button state")
    }
    refresh()
  }
  
  @IBAction func outputCopyButtonAction(_ sender: Any) {
    outputTextView.copyToClipboardFormatted()
  }
  
  func refresh() {
    do {
      let formatted = try formatterTool.format(input: inputTextView.string, options: options)
      outputTextView.textColor = .textColor
      outputTextView.string = formatted
      outputTextView.highlight()
    } catch {
      outputTextView.string = "Error: \(error)"
      outputTextView.textColor = .red
    }
    
  }
}

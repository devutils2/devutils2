//
//  UUIDToolViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 9/29/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class UUIDToolViewController: ToolViewController, NSTextFieldDelegate, ToolSettingDelegate {
  
  @IBOutlet weak var batchSizeTextField: NSTextField!
  @IBOutlet weak var uuidVersionButton: NSPopUpButton!
  @IBOutlet weak var namespaceInputView: NSView!
  @IBOutlet weak var namespaceTextField: NSTextField!
  @IBOutlet weak var nameTextField: NSTextField!
  @IBOutlet var generatedUUIDTextView: NSTextView!
  @IBOutlet weak var lowercasedCheckbox: NSButton!
  @IBOutlet weak var inputUUIDTextField: NSTextField!
  
  @IBOutlet weak var standardStringFormatOutputTextField: OutputTextField!
  @IBOutlet weak var rawContentsOutputTextField: OutputTextField!
  @IBOutlet weak var versionOutputTextField: OutputTextField!
  @IBOutlet weak var variantOutputTextField: OutputTextField!
  @IBOutlet weak var contentsTimeOutputTextField: OutputTextField!
  @IBOutlet weak var contentsClockOutputTextField: OutputTextField!
  @IBOutlet weak var contentsNodeOutputTextField: OutputTextField!
  @IBOutlet weak var contentStackView: NSStackView!
  
  var settingViewController: UUIDToolSettingViewController!
  var options: UUIDToolOptions!

  override func viewDidLoad() {
    super.viewDidLoad()
    batchSizeTextField.formatter = IntegerFormatter()
    
    generatedUUIDTextView.setupStandardTextview()
    
    loadOptions()
    
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
  }
  
  func loadOptions() {
    if self.settingViewController == nil {
      self.settingViewController = UUIDToolSettingViewController(
        nibName: "UUIDToolSettingViewController"
      )
      self.settingViewController.delegate = self
      self.settingViewController.ensureDefaults()
    }
    self.options = self.settingViewController.getOptions() as? UUIDToolOptions
  }
  
  func onOptionsChanged(options: ToolOptions) {
    self.options = options as? UUIDToolOptions
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    if !isViewLoaded {
      pendingInput = input
      return
    }
    inputUUIDTextField.stringValue = input.value.trimmingCharacters(in: .whitespacesAndNewlines)
    decode()
  }
  
  override func matchInput(input: String) -> Bool {
    loadOptions()

    if !self.options.autoDetect {
      return false
    }
    
    return UUID(uuidString: input.trimmingCharacters(in: .whitespacesAndNewlines)) != nil
  }
  
  func controlTextDidChange(_ obj: Notification) {
    decode()
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {
    inputUUIDTextField.stringValue = UUID().uuidString.lowercased()
    decode()
  }
  
  @IBAction func clearInputButtonAction(_ sender: Any) {
    inputUUIDTextField.stringValue = ""
    clearOuputs()
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputUUIDTextField.stringValue = NSPasteboard.general.string(forType: .string)?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
    decode()
  }
  
  @IBAction func uuidVersionButtonAction(_ sender: Any) {
    if (
      uuidVersionButton.titleOfSelectedItem == "UUID v3" ||
        uuidVersionButton.titleOfSelectedItem == "UUID v5"
      ) {
      namespaceInputView.isHidden = false
    } else {
      namespaceInputView.isHidden = true
    }
  }
  
  @IBAction func generateButtonAction(_ sender: Any) {
    if (
      uuidVersionButton.titleOfSelectedItem == "UUID v3" ||
        uuidVersionButton.titleOfSelectedItem == "UUID v5") && (
          UUID(uuidString: namespaceTextField.stringValue) == nil ||
            nameTextField.stringValue.count == 0
      ) {
      GeneralHelpers.alert(title: "Invalid inputs", text: "Please make sure your namespace is a valid UUID and name must be present.")
      return
    }
    
    guard let size = Int(batchSizeTextField?.stringValue ?? "") else {
      log.error("batch size somehow is not an int")
      return
    }
    
    if size > 3000 {
      if !GeneralHelpers.confirm(question: "Whoa, that's a big number!", text: "Are you sure you want to generate \(size) UUIDs?") {
        return
      }
    }
    
    generate()
  }
  
  @IBAction func copyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(generatedUUIDTextView.string, forType: .string)
  }
  
  func uuidv1() -> UUID {
    var uuid: uuid_t = (0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0)
    withUnsafeMutablePointer(to: &uuid) {
        $0.withMemoryRebound(to: UInt8.self, capacity: 16) {
            uuid_generate_time($0)
        }
    }

    return UUID(uuid: uuid)
  }
  
  func generate() {
    guard let size = Int(batchSizeTextField?.stringValue ?? "") else {
      log.error("batch size somehow is not an int")
      return
    }
    
    if batchSizeTextField?.stringValue.count == 0 {
      // clear
      generatedUUIDTextView.string = ""
    }
    
    var string = ""

    for _ in 1...size {
      if uuidVersionButton.titleOfSelectedItem == "UUID v4" {
        string += UUID().uuidString + "\n"
      } else if uuidVersionButton.titleOfSelectedItem == "UUID v1" {
        string += uuidv1().uuidString + "\n"
      } else if uuidVersionButton.titleOfSelectedItem == "UUID v3" {
        string += (
          UUID.init(
            uuidVersion: 3,
            namespace: UUID.init(uuidString: namespaceTextField.stringValue),
            name: nameTextField.stringValue)?.uuidString ?? ""
          ) + "\n"
      } else if uuidVersionButton.titleOfSelectedItem == "UUID v5" {
        string += (
          UUID.init(
            uuidVersion: 5,
            namespace: UUID.init(uuidString: namespaceTextField.stringValue),
            name: nameTextField.stringValue)?.uuidString ?? ""
          ) + "\n"
      } else {
        log.error("none of the valid selections is selected (?)")
      }
    }
    
    string = string.uppercased()
    
    if (lowercasedCheckbox.objectValue as? Bool) == true {
      string = string.lowercased()
    }
    
    generatedUUIDTextView.string = string
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    generatedUUIDTextView.string = ""
  }
  
  @IBAction func lowercasedButtonAction(_ sender: Any) {
    if (lowercasedCheckbox.objectValue as? Bool) == true {
      generatedUUIDTextView.string = generatedUUIDTextView.string.lowercased()
    } else {
      generatedUUIDTextView.string = generatedUUIDTextView.string.uppercased()
    }
  }
  
  @IBAction func settingButtonAction(_ sender: NSButton) {
    loadOptions()
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  func clearOuputs() {
    standardStringFormatOutputTextField.setValue("")
    rawContentsOutputTextField.setValue("")
    versionOutputTextField.setValue("")
    variantOutputTextField.setValue("")
    contentsTimeOutputTextField.setValue("")
    contentsClockOutputTextField.setValue("")
    contentsNodeOutputTextField.setValue("")
  }
  
  func decode() {
    guard let uuid = UUID(uuidString: inputUUIDTextField.stringValue) else {
      clearOuputs()
      return
    }
    
    standardStringFormatOutputTextField
      .setValue(uuid.uuidString.lowercased())
    rawContentsOutputTextField.setValue(uuid.rawContents)
    versionOutputTextField.setValue(uuid.version)
    variantOutputTextField.setValue(uuid.variant)
    contentsTimeOutputTextField.setValue(uuid.time.toISO())
    contentsNodeOutputTextField.setValue(uuid.node)
    contentsClockOutputTextField.setValue(String(uuid.clockId))
    
    if uuid.versionChar == "1" {
      contentStackView.isHidden = false
    } else {
      contentStackView.isHidden = true
    }
  }

  @IBAction func nsDNSButtonAction(_ sender: Any) {
    namespaceTextField.stringValue = UUID.namespace.DNS.uuidString.lowercased()
  }
  
  @IBAction func nsURLButtonAction(_ sender: Any) {
    namespaceTextField.stringValue = UUID.namespace.URL.uuidString.lowercased()
  }
  
  @IBAction func nsOIDButtonAction(_ sender: Any) {
    namespaceTextField.stringValue = UUID.namespace.OID.uuidString.lowercased()
  }
  
  @IBAction func nsX500ButtonAction(_ sender: Any) {
    namespaceTextField.stringValue = UUID.namespace.X500.uuidString.lowercased()
  }
  
  @IBAction func nsRandomButtonAction(_ sender: Any) {
    namespaceTextField.stringValue = UUID().uuidString.lowercased() // v4
  }
}

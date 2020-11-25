//
//  OutlineViewController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/16/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class OutlineViewController: NSViewController, NSOutlineViewDataSource, NSOutlineViewDelegate, NSTextFieldDelegate {
  
  class State {
    var selectedTool: Tool?
    var matchedTools: [Tool]
    
    init(selectedTool: Tool?, matchedTools: [Tool]) {
      self.selectedTool = selectedTool
      self.matchedTools = matchedTools
    }
    
    static func emptyState() -> State {
      return State.init(selectedTool: nil, matchedTools: [])
    }
  }
  
  @IBOutlet weak var outlineView: NSOutlineView!
  @IBOutlet weak var outlineScrollView: NSScrollView!
  @IBOutlet weak var versionLabel: NSTextField!
  @IBOutlet weak var toolSearchField: NSSearchField!
  
  var enableNotificationOnChange: Bool = true
  var state = State.emptyState()
  var tools: [Tool] = []
  
  struct NotificationNames {
    static let selectionChanged = "selectionChangedNotification"
    static let stateChanged = "stateChangedNotification"
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    outlineScrollView.backgroundColor = NSColor.clear
    outlineView.backgroundColor = NSColor.clear
    versionLabel.stringValue = """
    Developer Utilities for macOS \(AppState.getAppVersion())
    https://DevUtils2.app
    """
    
    refreshTools()
    outlineView.reloadData()
    outlineView.registerForDraggedTypes([.init("public.data")])
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleStateChanged(_:)),
      name: Notification.Name(OutlineViewController.NotificationNames.stateChanged),
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleToolsOrderChanged(_:)),
      name: AppDelegate.NotificationNames.AppToolsOrderChanged,
      object: nil)
  }
  
  func controlTextDidChange(_ obj: Notification) {
    log.debug("Search: \(toolSearchField.stringValue)")
    refreshTools()
    outlineView.reloadData()
  }
  
  func searchMatch(_ tool: Tool) -> Bool {
    let searchTerm = toolSearchField.stringValue.lowercased()
    if searchTerm == "" {
      return true
    }
    return tool.name.lowercased().contains(searchTerm)
  }
  
  func refreshTools() {
    var tools = AppState.tools.map { $0 } // shallow copy
    
    if AppState.getToolsSortOrder() == "custom" {
      // Notes: Keep the order when new tools are added/removed in the future
      if let orderedNames = AppState.getOrderedNames() {
        tools.sort { (t1, t2) -> Bool in
          let i1 = orderedNames.firstIndex { (name) -> Bool in
            return t1.name == name
          }
          if i1 == nil {
            return false
          }
          let i2 = orderedNames.firstIndex { (name) -> Bool in
            return t2.name == name
          }
          if i2 == nil {
            return false
          }
          return i1! < i2!
        }
      }
    } else if AppState.getToolsSortOrder() == "alphabet" {
      tools.sort { (t1, t2) -> Bool in
        return t2.name.compare(t1.name).rawValue > 0
      }
    }
    
    // search keyword
    // TODO: fuzzy search, UI text search (like in macOS's Preferences panel)
    tools = tools.filter{ searchMatch($0) }

    self.tools = tools
  }
  
  @objc
  func handleToolsOrderChanged(_ notification: Notification) {
    refreshList()
  }

  @objc
  func handleStateChanged(_ notification: Notification) {
    // Assuming selectRowIndexes triggers the delegate synchronously
    enableNotificationOnChange = false
    defer {
      enableNotificationOnChange = true
    }
    
    guard let newState = notification.object as? State else {
      log.debug("stateChanged event sent without a state object!")
      return
    }
    
    self.state = newState
    
    for tool in state.matchedTools {
      log.debug("showing matched icon for \(tool.id)")
    }
    
    guard
      let selectedTool = self.state.selectedTool,
      let index = tools.firstIndex(of: selectedTool) else {
        outlineView.deselectAll(self)
        return
    }
    
    outlineView.reloadData()
    
    // Select row index must come after reload data!
    outlineView.selectRowIndexes(.init(integer: index), byExtendingSelection: false)
  }
  
  func outlineView(_ outlineView: NSOutlineView, numberOfChildrenOfItem item: Any?) -> Int {
    return tools.count
  }
  
  func outlineView(_ outlineView: NSOutlineView, isItemExpandable item: Any) -> Bool {
    return false
  }
  
  func outlineView(_ outlineView: NSOutlineView, child index: Int, ofItem item: Any?) -> Any {
    return tools[index]
  }
  
  func outlineView(_ outlineView: NSOutlineView, heightOfRowByItem item: Any) -> CGFloat {
    return 24
  }
  
  func outlineView(_ outlineView: NSOutlineView, viewFor tableColumn: NSTableColumn?, item: Any) -> NSView? {
    var view: ToolOutlineTableCellView?
    view = outlineView.makeView(
      withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "ItemCell"),
      owner: self
    ) as? ToolOutlineTableCellView
    
    guard let tool = item as? Tool else {
      log.debug("outlineView called without an item")
      return nil
    }
    
    if let textField = view?.textField {
      textField.stringValue = tool.name
    }
    
    if let imageView = view?.imageView {
      imageView.image = tool.image
      imageView.imageScaling = .scaleProportionallyUpOrDown
    }
    
    if let statusImageView = view?.statusImageView {
      if self.state.matchedTools.firstIndex(of: tool) != nil {
        statusImageView.isHidden = false
      } else {
        statusImageView.isHidden = true
      }
    }
    return view
  }
  
  func outlineViewSelectionDidChange(_ notification: Notification) {
    if !enableNotificationOnChange {
      return
    }
    
    guard let outlineView = notification.object as? NSOutlineView else {
      return
    }
    let selectedIndex = outlineView.selectedRow
    NotificationCenter.default.post(
      name: Notification.Name(
        OutlineViewController.NotificationNames.selectionChanged
      ),
      object: outlineView.item(atRow: selectedIndex)
    )
  }
  
  @IBAction func sendFeedbackButtonAction(_ sender: Any) {
    let emailUrl = URL(string: "mailto:feedback@devutils2.app?subject=\("Feedback for DevUtils2.app version \(AppState.getAppVersion())".encodeUrl() ?? "unknown")")!
    
    if NSWorkspace.shared.open(emailUrl) {
      log.debug("Email client opened")
    } else {
      log.debug("Email client cannot be opened")
    }
  }
  
  func saveCustomOrder() {
    let orderedNames = self.tools.map{ $0.name }
    AppState.setOrderedNames(orderedNames)
    if AppState.getToolsSortOrder() != "custom" {
      (NSApp.delegate as! AppDelegate).toolsSortOrderCustomAction(self)
    }
    refreshList()
  }
  
  func refreshList() {
    refreshTools()
    outlineView.reloadData()
  }
  
  func outlineView(_ outlineView: NSOutlineView, acceptDrop info: NSDraggingInfo, item: Any?, childIndex index: Int) -> Bool {
    let pb = info.draggingPasteboard
    
    guard let toolName = pb.string(forType: .init(rawValue: "public.data")),
      let toolIndex = self.tools.firstIndex(where: { (t) -> Bool in
        return t.name == toolName
      }) else {
        return false
    }
    
    self.tools.move(from: toolIndex, to: index)
    saveCustomOrder()
    return true
  }
  
  func outlineView(_ outlineView: NSOutlineView, pasteboardWriterForItem item: Any) -> NSPasteboardWriting? {
    let pp = NSPasteboardItem()
    
    if let tool = item as? Tool {
      pp.setString( tool.name, forType: .init(rawValue: "public.data") )
      log.debug( "pb write \(tool.name)")
    } else {
      log.debug( "pb write, not a tool item \(item)")
    }
    
    return pp
  }
  
  func outlineView(_ outlineView: NSOutlineView, validateDrop info: NSDraggingInfo, proposedItem item: Any?, proposedChildIndex index: Int) -> NSDragOperation {
    
    if toolSearchField.stringValue.count > 0 {
      // No drag during search
      return []
    }
    
    if item != nil {
      // Do not allow drop to another tool
      // May add "folder" in the future
      return []
    }
    
    if index == -1 {
      // Do not allow drag to the "background"
      return []
    }
    return .move
  }
}

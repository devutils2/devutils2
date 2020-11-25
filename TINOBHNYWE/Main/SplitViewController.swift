//
//  SplitViewController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/16/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa

class SplitViewController: NSSplitViewController {
  var welcomeViewController: WelcomeViewController!
  var toolViewControllers = [String: ToolViewController]()
  
  private var verticalConstraints: [NSLayoutConstraint] = []
  private var horizontalConstraints: [NSLayoutConstraint] = []
  
  private var detailViewController: DetailViewController {
    let rightSplitViewItem = splitViewItems[1]
    return rightSplitViewItem.viewController as! DetailViewController
  }
  
  private var hasChildViewController: Bool {
    return !detailViewController.children.isEmpty
  }

  override func viewDidLoad() {
    super.viewDidLoad()
    
    /** Note: We keep the left split view item from growing as the window grows by setting its
     hugging priority to 200, and the right to 199. The view with the lowest priority will be
     the first to take on additional width if the split view grows or shrinks.
     */
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleSelectionChange(_:)),
      name: Notification.Name(OutlineViewController.NotificationNames.selectionChanged),
      object: nil)
    
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAppActivated(_:)),
      name: AppDelegate.NotificationNames.AppActivated,
      object: nil)
    
    setupViewControllers()
    
    // Show welcome view
    setTool(nil)
  }
  
  // MARK: Detail View Controller Management

  // TODO: this means all the views are always activated (retained in memory)
  // TODO: probably should deallocate unused views.
  func setupViewControllers() {
    self.welcomeViewController = WelcomeViewController(
      nibName: "WelcomeViewController"
    )
    
    for tool in AppState.tools {
      log.debug("Init view controller for: \(tool.viewControllerType.className())")
      
      var vc: ToolViewController
      
      if let t = tool.viewControllerType as? SharedEndecodeViewController.Type {
        let impl = tool.implementation as! EndecodeTool.Type
        var settingVc: ToolSettingViewController? = nil
        if let settingVcType = tool.settingViewControllerType {
          settingVc = settingVcType.init(nibName: settingVcType.className())
        }
        vc = t.init(endecodeTool: impl.init(), settingViewController: settingVc)
      } else if let t = tool.viewControllerType as? SharedFormatterViewController.Type {
        let impl = tool.implementation as! FormatterTool.Type
        var settingVc: ToolSettingViewController? = nil
        if let settingVcType = tool.settingViewControllerType {
          settingVc = settingVcType.init(nibName: settingVcType.className())
        }
        vc = t.init(formatterTool: impl.init(), settingViewController: settingVc)
      } else {
        vc = tool.viewControllerType.init(nibName: tool.viewControllerType.className())
      }
      
      toolViewControllers[tool.id] = vc
    }
  }
  
  private func embedChildViewController(_ childViewController: NSViewController) {
    // To embed a new child view controller.
    let currentDetailVC = detailViewController
    currentDetailVC.addChild(childViewController)
    let contentView = currentDetailVC.view.subviews.first { (view) -> Bool in
      return view.identifier?.rawValue == "ContentView"
    }
    if contentView == nil {
      log.debug("Content view is nil!")
      return
    }
    contentView?.addSubview(childViewController.view)
    childViewController.view.fillParent(parent: contentView!)
//    currentDetailVC.view.addSubview(childViewController.view)
//    childViewController.view.fillParent(parent: currentDetailVC.view)
  }
  
  @objc
  func handleAppActivated(_ notification: Notification) {
    guard let activationValue = notification.object as? ActivationValue else {
      return
    }

    let string = activationValue.value
    
    var matchedTools: [Tool] = []
    
    for tool in AppState.tools {
      guard let vc = toolViewControllers[tool.id] else {
        log.debug("View controller for \(tool.id) not found")
        continue
      }
      
      vc.ensureDefault()
      
      let matched = vc.matchInput(input: string)
      log.debug("Matching input: \(tool.id): \(matched)")
      
      if (matched) {
        matchedTools.append(tool)
      }
    }
    log.debug("Matched \(matchedTools.count) tools.")
    
    // For now let's just show the first matched tool, additional logic to
    // set priority can be put here
    let autoSelectedTool = matchedTools.first
    
    // Update OutlineViewController
    NotificationCenter.default.post(
      name: Notification.Name(
        OutlineViewController.NotificationNames.stateChanged
      ),
      object: OutlineViewController.State.init(
        selectedTool: autoSelectedTool, matchedTools: matchedTools
      )
    )
    
    setTool(autoSelectedTool)
    self.activateTools(tools: matchedTools, input: activationValue)
  }
  
  // This handler will be triggered from OutlineViewController when user select tools
  @objc
  private func handleSelectionChange(_ notification: Notification) {
    let tool = notification.object as? Tool
    setTool(tool)
  }
  
  func setTool(_ tool: Tool?) {
    log.debug("setTool: \(tool?.name)")
    let currentDetailVC = detailViewController
    var vcForDetail: ToolViewController!
    
    if let id = tool?.id {
      vcForDetail = toolViewControllers[id]
    }
    
    log.debug("lookup vcForDetail using tool id \(tool?.id): \(vcForDetail)")

    if vcForDetail == nil {
      vcForDetail = welcomeViewController
    }
    detailViewController.navLabel.stringValue = tool?.name ?? ""
    
    if hasChildViewController && currentDetailVC.children[0] != vcForDetail {
      clearCurrentDetailView()
      embedChildViewController(vcForDetail!)
    } else {
      if !hasChildViewController {
        // We don't have a child view controller so embed the new one.
        embedChildViewController(vcForDetail!)
      }
    }
  }
  
  func activateTools(tools: [Tool], input: ActivationValue) {
    if tools.count == 0 {
      log.debug("No tool to activate. Showing input in welcome screen.")
      welcomeViewController.activate(input: input)
      return
    }
    
    log.debug("Activating tools: \(tools). Using input: \(input)")
    
    for tool in tools {
      guard let vc = toolViewControllers[tool.id] else {
        log.debug("Need to activate tool \(tool.id) but view controller not found!")
        continue
      }
      
      vc.clearPendingInput()
      vc.activate(input: input)
    }
  }
  
  func clearCurrentDetailView() {
    if hasChildViewController {
      detailViewController.removeChild(at: 0)
      let contentView = detailViewController.view.subviews.first { (view) -> Bool in
        return view.identifier?.rawValue == "ContentView"
      }
      if contentView == nil {
        log.debug("contentView is nil!!")
        return
      }
      if contentView!.subviews.count > 0 {
        contentView!.subviews[0].removeFromSuperview()
      } else {
        // It should only have 1 subview in contentView
        log.debug("contentView.subviews.count: \(contentView!.subviews.count)")
      }
    }
  }
}

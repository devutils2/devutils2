//
//  HTMLPreviewViewController.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/4/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import WebKit

class HTMLPreviewViewController: ToolViewController, WKUIDelegate, NSTextViewDelegate, WKNavigationDelegate, ToolSettingDelegate {
  
  @IBOutlet var inputHTMLTextView: NSTextView!
  @IBOutlet weak var webViewContainer: NSView!
  private var webView: WKWebView!
  
  var settingViewController: HTMLPreviewSettingViewController!
  var options: HTMLPreviewOptions!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    loadOptions()
    setupWebView()
    
    inputHTMLTextView.setupStandardTextview()
        
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
  }
  
  func setupWebView() {
    let preferences = WKPreferences()
    preferences.javaScriptEnabled = options.enableJavaScript
    let webConfiguration = WKWebViewConfiguration()
    webConfiguration.preferences = preferences
    let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: self.webViewContainer.frame.size.width, height: self.webViewContainer.frame.size.height))
    self.webView = WKWebView(frame: customFrame , configuration: webConfiguration)
    webView.translatesAutoresizingMaskIntoConstraints = false
    self.webViewContainer.addSubview(webView)
    webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
    webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
    webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
    webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
    webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
    webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")
    webView.uiDelegate = self
    webView.navigationDelegate = self
    
    // Block all URLs except those starting with "file://"
    let blockRules = """
    [
      {
        "trigger": {
          "url-filter": ".*"
        },
        "action": {
          "type": "block"
        }
      },
      {
        "trigger": {
          "url-filter": "file://.*"
        },
        "action": {
          "type": "ignore-previous-rules"
        }
      }
    ]
    """
    
    if !options.enableNetwork {
      if #available(OSX 10.13, *) {
        WKContentRuleListStore.default().compileContentRuleList(
          forIdentifier: "ContentBlockingRules",
          encodedContentRuleList: blockRules) { (contentRuleList, error) in
            if let error = error {
              log.error("Unable to parse blocking rules: \(error)")
              return
            }
            
            let configuration = self.webView.configuration
            configuration.userContentController.add(contentRuleList!)
        }
      }
    }
    
    
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    if !isViewLoaded {
      pendingInput = input
      return
    }
    inputHTMLTextView.setStringRetrainUndo(input.value)
    refresh()
  }
  
  func loadOptions() {
    if self.settingViewController == nil {
      self.settingViewController = HTMLPreviewSettingViewController(
        nibName: "HTMLPreviewSettingViewController"
      )
      self.settingViewController.delegate = self
      self.settingViewController.ensureDefaults()
    }
    self.options = self.settingViewController.getOptions() as? HTMLPreviewOptions
  }
  
  func onOptionsChanged(options: ToolOptions) {
    self.options = options as? HTMLPreviewOptions
    setupWebView()
    refresh()
  }
  
  // No navigation
  func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    if options.enableNavigation {
      decisionHandler(.allow)
      return
    }
    
    if navigationAction.request.url?.host == nil {
      decisionHandler(.allow)
      return
    }
    
    log.info("navigate prevented: \(navigationAction.request.url?.host)")
    decisionHandler(.cancel)
  }
  
  func textDidChange(_ notification: Notification) {
    refresh()
  }
  
  func refresh() {
    webView.loadHTMLString(inputHTMLTextView.string, baseURL: nil)
  }
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputHTMLTextView.setStringRetrainUndo(NSPasteboard.general.string(forType: .string) ?? "")
    refresh()
  }
  @IBAction func sampleButtonAction(_ sender: Any) {
    inputHTMLTextView.setStringRetrainUndo("""
    <!DOCTYPE html>
    <html>
    <body>

    <style>
      h1 { color: blue; }
    </style>

    <h1>Hello from DevUtils2.app!</h1>
    <p>This is a sample HTML page. By default, JavaScript and link navigation is disabled. You can click the gear icon to enable it.</p>
    <p>Right click > Inspect Element also works.</p>
    </body>
    </html>
    """)
    refresh()
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputHTMLTextView.setStringRetrainUndo("")
    refresh()
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
  
  @IBAction func reloadButtonAction(_ sender: Any) {
    refresh()
  }
}

//
//  JWTViewController.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/16/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Cocoa
import SwiftJWT

class CustomClaims: Claims {
  let json: String
  
  init(json: String) {
    self.json = json
  }
  
  func encode() throws -> String {
    if let jsonData: Data = json.data(using: .utf8) {
      return JWTEncoder.base64urlEncodedString(data: jsonData)
    }
    return ""
  }
}


class JWTViewController: ToolViewController, NSTextViewDelegate, NSTextFieldDelegate {
  @IBOutlet var inputTextView: NSTextView!
  @IBOutlet var headerTextView: JSONTextView!
  @IBOutlet var payloadTextView: JSONTextView!
  @IBOutlet weak var secretTextField: NSTextField!
  @IBOutlet weak var secretLabel: NSTextField!
  @IBOutlet weak var secretLabel2: NSTextField!
  @IBOutlet weak var verificationStatusLabel: NSTextField!
  @IBOutlet weak var verificationStatusBox: NSBox!
  @IBOutlet weak var algoPopUpButton: NSPopUpButton!
  @IBOutlet weak var secretTabView: NSTabView!
  @IBOutlet var publicKeyTextView: NSTextView!
  @IBOutlet var privateKeyTextView: NSTextView!
  @IBOutlet weak var publicPrivateLabel: NSTextField!
  @IBOutlet weak var publicPrivateLabel2: NSTextField!
  @IBOutlet weak var publicPrivateLabel3: NSTextField!
  
  var settingViewController: JWTSettingViewController!
  
  override func matchInput(input: String) -> Bool {
    guard let autoDetect = NSUserDefaultsController.shared.value(
      forKeyPath: "values.jwt-auto-detect-well-formed") as? Bool else {
      return false
    }
    if !autoDetect {
      return false
    }
    
    let components = input.trimmingCharacters(in: .whitespacesAndNewlines).components(separatedBy: ".")
    log.debug("JWT match input \(components.count)")
    if components.count != 3 {
      return false
    }
    if components[0].fromBase64() == nil {
      return false
    }
    if components[1].fromBase64() == nil {
      return false
    }
    return true
  }
  
  override func activate(input: ActivationValue) {
    super.activate(input: input)
    if !isViewLoaded {
      pendingInput = input
      return
    }
    inputTextView.string = input.value
    refreshJWTSyntaxHighlight()
    decodeJWT()
  }
  
  func setLabelTemplateSecret(_ algo: String) {
    let label = """
    HMACSHA\(algo.replacingOccurrences(of: "HS", with: ""))(
      base64UrlEncode(header) + "." +
      base64UrlEncode(payload),
    """
    secretLabel.stringValue = label
  }
  
  func setLabelTemplatePublicPrivateKey(_ algo: String) {
    var funcName = ""
    if algo.starts(with: "RS") {
      funcName = "RSASHA\(algo.replacingOccurrences(of: "RS", with: ""))"
    } else if algo.starts(with: "ES") {
      funcName = "ECDSASHA\(algo.replacingOccurrences(of: "ES", with: ""))"
    } else if algo.starts(with: "PS") {
      funcName = "RSAPSSSHA\(algo.replacingOccurrences(of: "PS", with: ""))"
    }
    
    let label = """
    \(funcName)(
      base64UrlEncode(header) + "." +
      base64UrlEncode(payload),
    """
    
    publicPrivateLabel.stringValue = label
  }
  
  func detectAlgoFromHeader() {
    var dict: [String: Any]

    let components = inputTextView.string.components(separatedBy: ".")
    
    guard let jsonData = JWTDecoder.data(base64urlEncoded: components[0]) else {
      return
    }

    do {
      dict = try (JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:])
    } catch {
      return
    }
    if let alg = dict["alg"] as? String {
      algoPopUpButton.selectItem(withTitle: alg.uppercased())
      setCurrentAlgo(alg.uppercased())
    }
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    inputTextView.setupStandardTextview()
    headerTextView.setupStandardTextview()
    payloadTextView.setupStandardTextview()
    publicKeyTextView.setupStandardTextview()
    privateKeyTextView.setupStandardTextview()
    
    headerTextView.setHighlight(false)
    headerTextView.textColor = #colorLiteral(red: 0.9843137255, green: 0.003921568627, blue: 0.3568627451, alpha: 1)
    payloadTextView.setHighlight(false)
    payloadTextView.textColor = #colorLiteral(red: 0.8392156863, green: 0.2274509804, blue: 1, alpha: 1)
    secretLabel.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    secretLabel2.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    publicPrivateLabel.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    publicPrivateLabel2.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    publicPrivateLabel3.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    publicKeyTextView.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    privateKeyTextView.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
    secretTextField.textColor = #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)

    clear()
    JWTViewController.ensureDefaults()
    
    if pendingInput != nil {
      activate(input: pendingInput!)
      pendingInput = nil
    }
  }
  
  @IBAction func algoPopUpButtonAction(_ sender: Any) {
    if algoPopUpButton.titleOfSelectedItem != nil {
      setCurrentAlgo(algoPopUpButton.titleOfSelectedItem!)
    }
    encodeJWT()
  }
  
  // set header, set label, set secret template, set secret sample if not any yet
  func setCurrentAlgo(_ algo: String) {
    // Header
    updateHeaderAlgo(algo)
    
    // secret template
    if algo.starts(with: "HS") {
      setLabelTemplateSecret(algo)
      secretTabView.selectTabViewItem(at: 0)
    } else {
      setLabelTemplatePublicPrivateKey(algo)
      secretTabView.selectTabViewItem(at: 1)
    }
    
  }
  
  func updateHeaderAlgo(_ algo: String) {
    var dict: [String: Any]

    guard let jsonData = headerTextView.string.data(using: .utf8) else {
      return
    }

    do {
      dict = try (JSONSerialization.jsonObject(with: jsonData, options: []) as? [String: Any] ?? [:])
    } catch {
      return
    }
    dict["alg"] = algo
    
    var updatedJsonData: Data
    do {
      updatedJsonData = try JSONSerialization.data(withJSONObject: dict, options: .init())
    } catch {
      return
    }
    
    if let json = String(data: updatedJsonData, encoding: .utf8) {
      headerTextView.setJSONString(json)
    }
  }
  
  func textDidChange(_ notification: Notification) {
    guard let textView = notification.object as? NSTextView else { return }
    clearStatus()
    
    if textView.identifier?.rawValue == "encoded" {
      refreshJWTSyntaxHighlight()
      decodeJWT()
    } else {
      encodeJWT()
    }
  }
  
  func controlTextDidChange(_ obj: Notification) {
    encodeJWT()
  }
  
  func encodeJWT() {
    var header: Header
    do {
      header = try Header.FromJSON(json: headerTextView.string)
    } catch {
      log.debug("\(error)")
      showInvalidField("Header", "\(error)")
      return
    }
    
    let payload = payloadTextView.string
    let payloadData = payload.data(using: .utf8)
    if payloadData == nil {
      showInvalidField("Payload", "Invalid Encoding")
      return
    }
    
    if let jsonDataToVerify = payload.data(using: String.Encoding.utf8)  {
      do {
        try JSONSerialization.jsonObject(with: jsonDataToVerify)
      } catch {
        showInvalidField("Payload", "Invalid JSON")
        return
      }
    } else {
      showInvalidField("Payload", "Invalid Encoding")
      return
    }

    let pretifiedPayload = payload.pretifyJSON()!
    do {
      let jwtSigner = try getSignerWithSecret()
      var myJWT = JWT<CustomClaims>(header: header, claims: .init(json: pretifiedPayload))
      var signedJWT: String = ""
      do {
        signedJWT = try myJWT.sign(using: jwtSigner)
      } catch {
        log.debug("Sign error: \(error)")
        showInvalidField("Inputs", "Cannot sign, please check your inputs")
        return
      }
      inputTextView.string = signedJWT
      refreshJWTSyntaxHighlight()
      refreshStatus()
    } catch {
      showInvalidField("", "\(error)")
    }
  }
  
  func showInvalidField(_ field: String, _ err: String) {
    verificationStatusLabel.stringValue = "Invalid \(field): \(err)"
    verificationStatusBox.fillColor = .red
    verificationStatusLabel.textColor = .black
  }
  
  func decodeJWT() {
    if inputTextView.string == "" {
      clear()
      return
    }
    
    var success = true
    
    let components = inputTextView.string.components(separatedBy: ".")
    
    headerTextView.string = ""
    if let header = JWTDecoder.data(base64urlEncoded: components[0]) {
      if let headerJson = String(data: header, encoding: .utf8) {
        headerTextView.setJSONString(headerJson)
      } else {
        showInvalidField("Header", "Encoding Error")
        success = false
      }
    } else {
      showInvalidField("Header", "Base64 not decodable")
      success = false
    }
    
    payloadTextView.string = ""
    if components.count > 1 {
      if let payload = JWTDecoder.data(base64urlEncoded: components[1]) {
        if let payloadJson = String(data: payload, encoding: .utf8) {
          payloadTextView.setJSONString(payloadJson)
        } else {
          showInvalidField("Payload", "Encoding Error")
          success = false
        }
      } else {
        showInvalidField("Payload", "Base64 not decodable")
        success = false
      }
    }
    
    if success {
      detectAlgoFromHeader()
      refreshStatus()
    }
  }
  
  func getVerifierWithSecret() throws -> JWTVerifier {
    guard let algo = algoPopUpButton.titleOfSelectedItem else {
      throw NSError(domain: "No Algorithm Selected", code: 0, userInfo: nil)
    }
    
    if algo.starts(with: "HS") {
      guard let secretData = secretTextField.stringValue.data(using: .utf8) else {
        throw NSError(domain: "Invalid Encoding", code: 0, userInfo: nil)
      }
      
      if algo == "HS256" {
        return JWTVerifier.hs256(key: secretData)
      }
      if algo == "HS384" {
        return JWTVerifier.hs384(key: secretData)
      }
      if algo == "HS512" {
        return JWTVerifier.hs512(key: secretData)
      }
    }
    
    guard let publicKeyData = publicKeyTextView.string.data(using: .utf8) else {
      throw NSError(domain: "Invalid Encoding", code: 0, userInfo: nil)
    }
    
    if algo == "RS256" {
      return JWTVerifier.rs256(publicKey: publicKeyData)
    }
    if algo == "RS384" {
      return JWTVerifier.rs384(publicKey: publicKeyData)
    }
    if algo == "RS512" {
      return JWTVerifier.rs512(publicKey: publicKeyData)
    }
    
    if algo == "PS256" {
      return JWTVerifier.ps256(publicKey: publicKeyData)
    }
    if algo == "PS384" {
      return JWTVerifier.ps384(publicKey: publicKeyData)
    }
    if algo == "PS512" {
      return JWTVerifier.ps512(publicKey: publicKeyData)
    }

    if algo.starts(with: "ES") {
      if #available(OSX 10.13, *) {
        if algo == "ES256" {
          return JWTVerifier.es256(publicKey: publicKeyData)
        }
        if algo == "ES384" {
          return JWTVerifier.es384(publicKey: publicKeyData)
        }
        if algo == "ES512" {
          return JWTVerifier.es512(publicKey: publicKeyData)
        }
      } else {
        throw NSError(domain: "Requires OSX 10.13+", code: 0, userInfo: nil)
      }
    }
    
    throw NSError(domain: "Algorithm Not Supported", code: 0, userInfo: nil)
  }
  func getSignerWithSecret() throws -> JWTSigner {
    guard let algo = algoPopUpButton.titleOfSelectedItem else {
      throw NSError(domain: "No Algorithm Selected", code: 0, userInfo: nil)
    }
    
    if algo.starts(with: "HS") {
      guard let secretData = secretTextField.stringValue.data(using: .utf8) else {
        throw NSError(domain: "Invalid Encoding", code: 0, userInfo: nil)
      }
      
      if algo == "HS256" {
        return JWTSigner.hs256(key: secretData)
      }
      if algo == "HS384" {
        return JWTSigner.hs384(key: secretData)
      }
      if algo == "HS512" {
        return JWTSigner.hs512(key: secretData)
      }
    }
    
    guard let privateKeyData = privateKeyTextView.string.data(using: .utf8) else {
      throw NSError(domain: "Invalid Encoding", code: 0, userInfo: nil)
    }
    if algo.starts(with: "ES") {
      if #available(OSX 10.13, *) {
        if algo == "ES256" {
          return JWTSigner.es256(privateKey: privateKeyData)
        }
        if algo == "ES384" {
          return JWTSigner.es384(privateKey: privateKeyData)
        }
        if algo == "ES512" {
          return JWTSigner.es512(privateKey: privateKeyData)
        }
      } else {
        throw NSError(domain: "Requires OSX 10.13+", code: 0, userInfo: nil)
      }
    }
    
    if algo == "RS256" {
      return JWTSigner.rs256(privateKey: privateKeyData)
    }
    if algo == "RS384" {
      return JWTSigner.rs384(privateKey: privateKeyData)
    }
    if algo == "RS512" {
      return JWTSigner.rs512(privateKey: privateKeyData)
    }
    
    if algo == "PS256" {
      return JWTSigner.ps256(privateKey: privateKeyData)
    }
    if algo == "PS384" {
      return JWTSigner.ps384(privateKey: privateKeyData)
    }
    if algo == "PS512" {
      return JWTSigner.ps512(privateKey: privateKeyData)
    }
    
    throw NSError(domain: "Algorithm Not Supported", code: 0, userInfo: nil)
  }
  
  func refreshStatus() {
    do {
      let verifier = try getVerifierWithSecret()
      let status = JWT<ClaimsStandardJWT>.verify(inputTextView.string, using: verifier)
      
      
      if status {
        verificationStatusLabel.stringValue = "✓ Signature Verified"
        verificationStatusBox.fillColor = .green
      } else {
        verificationStatusLabel.stringValue = "ⅹ Signature Invalid"
        verificationStatusBox.fillColor = .red
      }
      verificationStatusLabel.textColor = .black
    } catch {
      log.debug("\(error)")
      showInvalidField("Algorithm", "\(error.localizedDescription)")
    }
  }
  
  
  func clear() {
    clearStatus()
    payloadTextView.setJSONString("{}")
    headerTextView.setJSONString("{}")
  }
  
  func clearStatus() {
    verificationStatusLabel.stringValue = "Verification Status: No Input"
    verificationStatusBox.fillColor = .controlBackgroundColor
    verificationStatusLabel.textColor = .textColor
  }
  
  @IBAction func sampleButtonAction(_ sender: Any) {
    headerTextView.setJSONString(
      """
      {"typ": "JWT", "alg": "\(algoPopUpButton.titleOfSelectedItem ?? "HS256")"}
      """
    )
    
    payloadTextView.setJSONString(
      """
      {
        "sub": "1234567890",
        "name": "John Doe",
        "iat": 1516239022
      }
      """
    )
    
    secretTextField.stringValue = "your-secret"
    
    if let algo = algoPopUpButton.titleOfSelectedItem {
      if algo.starts(with: "RS") {
        publicKeyTextView.string = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnzyis1ZjfNB0bBgKFMSv
        vkTtwlvBsaJq7S5wA+kzeVOVpVWwkWdVha4s38XM/pa/yr47av7+z3VTmvDRyAHc
        aT92whREFpLv9cj5lTeJSibyr/Mrm/YtjCZVWgaOYIhwrXwKLqPr/11inWsAkfIy
        tvHWTxZYEcXLgAXFuUuaS3uF9gEiNQwzGTU1v0FqkqTBr4B8nW3HCN47XUu0t8Y0
        e+lf4s4OxQawWD79J9/5d3Ry0vbV3Am1FtGJiJvOwRsIfVChDpYStTcHTCMqtvWb
        V6L11BWkpzGXSW4Hv43qa+GSYOD2QU68Mb59oSk2OB+BtOLpJofmbGEGgvmwyCI9
        MwIDAQAB
        -----END PUBLIC KEY-----
        """
        privateKeyTextView.string = """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEogIBAAKCAQEAnzyis1ZjfNB0bBgKFMSvvkTtwlvBsaJq7S5wA+kzeVOVpVWw
        kWdVha4s38XM/pa/yr47av7+z3VTmvDRyAHcaT92whREFpLv9cj5lTeJSibyr/Mr
        m/YtjCZVWgaOYIhwrXwKLqPr/11inWsAkfIytvHWTxZYEcXLgAXFuUuaS3uF9gEi
        NQwzGTU1v0FqkqTBr4B8nW3HCN47XUu0t8Y0e+lf4s4OxQawWD79J9/5d3Ry0vbV
        3Am1FtGJiJvOwRsIfVChDpYStTcHTCMqtvWbV6L11BWkpzGXSW4Hv43qa+GSYOD2
        QU68Mb59oSk2OB+BtOLpJofmbGEGgvmwyCI9MwIDAQABAoIBACiARq2wkltjtcjs
        kFvZ7w1JAORHbEufEO1Eu27zOIlqbgyAcAl7q+/1bip4Z/x1IVES84/yTaM8p0go
        amMhvgry/mS8vNi1BN2SAZEnb/7xSxbflb70bX9RHLJqKnp5GZe2jexw+wyXlwaM
        +bclUCrh9e1ltH7IvUrRrQnFJfh+is1fRon9Co9Li0GwoN0x0byrrngU8Ak3Y6D9
        D8GjQA4Elm94ST3izJv8iCOLSDBmzsPsXfcCUZfmTfZ5DbUDMbMxRnSo3nQeoKGC
        0Lj9FkWcfmLcpGlSXTO+Ww1L7EGq+PT3NtRae1FZPwjddQ1/4V905kyQFLamAA5Y
        lSpE2wkCgYEAy1OPLQcZt4NQnQzPz2SBJqQN2P5u3vXl+zNVKP8w4eBv0vWuJJF+
        hkGNnSxXQrTkvDOIUddSKOzHHgSg4nY6K02ecyT0PPm/UZvtRpWrnBjcEVtHEJNp
        bU9pLD5iZ0J9sbzPU/LxPmuAP2Bs8JmTn6aFRspFrP7W0s1Nmk2jsm0CgYEAyH0X
        +jpoqxj4efZfkUrg5GbSEhf+dZglf0tTOA5bVg8IYwtmNk/pniLG/zI7c+GlTc9B
        BwfMr59EzBq/eFMI7+LgXaVUsM/sS4Ry+yeK6SJx/otIMWtDfqxsLD8CPMCRvecC
        2Pip4uSgrl0MOebl9XKp57GoaUWRWRHqwV4Y6h8CgYAZhI4mh4qZtnhKjY4TKDjx
        QYufXSdLAi9v3FxmvchDwOgn4L+PRVdMwDNms2bsL0m5uPn104EzM6w1vzz1zwKz
        5pTpPI0OjgWN13Tq8+PKvm/4Ga2MjgOgPWQkslulO/oMcXbPwWC3hcRdr9tcQtn9
        Imf9n2spL/6EDFId+Hp/7QKBgAqlWdiXsWckdE1Fn91/NGHsc8syKvjjk1onDcw0
        NvVi5vcba9oGdElJX3e9mxqUKMrw7msJJv1MX8LWyMQC5L6YNYHDfbPF1q5L4i8j
        8mRex97UVokJQRRA452V2vCO6S5ETgpnad36de3MUxHgCOX3qL382Qx9/THVmbma
        3YfRAoGAUxL/Eu5yvMK8SAt/dJK6FedngcM3JEFNplmtLYVLWhkIlNRGDwkg3I5K
        y18Ae9n7dHVueyslrb6weq7dTkYDi3iOYRW8HRkIQh06wEdbxt0shTzAJvvCQfrB
        jg/3747WSsf/zBTcHihTRBdAv6OmdhV4/dD5YBfLAkLrd+mX7iE=
        -----END RSA PRIVATE KEY-----
        """
      } else if algo == "ES256" {
        publicKeyTextView.string = """
        -----BEGIN PUBLIC KEY-----
        MFkwEwYHKoZIzj0CAQYIKoZIzj0DAQcDQgAEEVs/o5+uQbTjL3chynL4wXgUg2R9
        q9UU8I5mEovUf86QZ7kOBIjJwqnzD1omageEHWwHdBO6B+dFabmdT9POxg==
        -----END PUBLIC KEY-----
        """
        
        privateKeyTextView.string = """
        -----BEGIN PRIVATE KEY-----
        MIGHAgEAMBMGByqGSM49AgEGCCqGSM49AwEHBG0wawIBAQQgevZzL1gdAFr88hb2
        OF/2NxApJCzGCEDdfSp6VQO30hyhRANCAAQRWz+jn65BtOMvdyHKcvjBeBSDZH2r
        1RTwjmYSi9R/zpBnuQ4EiMnCqfMPWiZqB4QdbAd0E7oH50VpuZ1P087G
        -----END PRIVATE KEY-----
        """
      } else if algo == "ES384" {
        publicKeyTextView.string = """
        -----BEGIN PUBLIC KEY-----
        MHYwEAYHKoZIzj0CAQYFK4EEACIDYgAEC1uWSXj2czCDwMTLWV5BFmwxdM6PX9p+
        Pk9Yf9rIf374m5XP1U8q79dBhLSIuaojsvOT39UUcPJROSD1FqYLued0rXiooIii
        1D3jaW6pmGVJFhodzC31cy5sfOYotrzF
        -----END PUBLIC KEY-----
        """
        
        privateKeyTextView.string = """
        -----BEGIN EC PRIVATE KEY-----
        MIGkAgEBBDCAHpFQ62QnGCEvYh/pE9QmR1C9aLcDItRbslbmhen/h1tt8AyMhske
        enT+rAyyPhGgBwYFK4EEACKhZANiAAQLW5ZJePZzMIPAxMtZXkEWbDF0zo9f2n4+
        T1h/2sh/fviblc/VTyrv10GEtIi5qiOy85Pf1RRw8lE5IPUWpgu553SteKigiKLU
        PeNpbqmYZUkWGh3MLfVzLmx85ii2vMU=
        -----END EC PRIVATE KEY-----
        """
      } else if algo == "ES512" {
        publicKeyTextView.string = """
        -----BEGIN PUBLIC KEY-----
        MIGbMBAGByqGSM49AgEGBSuBBAAjA4GGAAQBgc4HZz+/fBbC7lmEww0AO3NK9wVZ
        PDZ0VEnsaUFLEYpTzb90nITtJUcPUbvOsdZIZ1Q8fnbquAYgxXL5UgHMoywAib47
        6MkyyYgPk0BXZq3mq4zImTRNuaU9slj9TVJ3ScT3L1bXwVuPJDzpr5GOFpaj+WwM
        Al8G7CqwoJOsW7Kddns=
        -----END PUBLIC KEY-----
        """
        
        privateKeyTextView.string = """
        -----BEGIN EC PRIVATE KEY-----
        MIHcAgEBBEIBiyAa7aRHFDCh2qga9sTUGINE5jHAFnmM8xWeT/uni5I4tNqhV5Xx
        0pDrmCV9mbroFtfEa0XVfKuMAxxfZ6LM/yKgBwYFK4EEACOhgYkDgYYABAGBzgdn
        P798FsLuWYTDDQA7c0r3BVk8NnRUSexpQUsRilPNv3SchO0lRw9Ru86x1khnVDx+
        duq4BiDFcvlSAcyjLACJvjvoyTLJiA+TQFdmrearjMiZNE25pT2yWP1NUndJxPcv
        VtfBW48kPOmvkY4WlqP5bAwCXwbsKrCgk6xbsp12ew==
        -----END EC PRIVATE KEY-----
        """
        
      } else if algo.starts(with: "PS") {
        publicKeyTextView.string = """
        -----BEGIN PUBLIC KEY-----
        MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAnzyis1ZjfNB0bBgKFMSv
        vkTtwlvBsaJq7S5wA+kzeVOVpVWwkWdVha4s38XM/pa/yr47av7+z3VTmvDRyAHc
        aT92whREFpLv9cj5lTeJSibyr/Mrm/YtjCZVWgaOYIhwrXwKLqPr/11inWsAkfIy
        tvHWTxZYEcXLgAXFuUuaS3uF9gEiNQwzGTU1v0FqkqTBr4B8nW3HCN47XUu0t8Y0
        e+lf4s4OxQawWD79J9/5d3Ry0vbV3Am1FtGJiJvOwRsIfVChDpYStTcHTCMqtvWb
        V6L11BWkpzGXSW4Hv43qa+GSYOD2QU68Mb59oSk2OB+BtOLpJofmbGEGgvmwyCI9
        MwIDAQAB
        -----END PUBLIC KEY-----
        """
        privateKeyTextView.string = """
        -----BEGIN RSA PRIVATE KEY-----
        MIIEogIBAAKCAQEAnzyis1ZjfNB0bBgKFMSvvkTtwlvBsaJq7S5wA+kzeVOVpVWw
        kWdVha4s38XM/pa/yr47av7+z3VTmvDRyAHcaT92whREFpLv9cj5lTeJSibyr/Mr
        m/YtjCZVWgaOYIhwrXwKLqPr/11inWsAkfIytvHWTxZYEcXLgAXFuUuaS3uF9gEi
        NQwzGTU1v0FqkqTBr4B8nW3HCN47XUu0t8Y0e+lf4s4OxQawWD79J9/5d3Ry0vbV
        3Am1FtGJiJvOwRsIfVChDpYStTcHTCMqtvWbV6L11BWkpzGXSW4Hv43qa+GSYOD2
        QU68Mb59oSk2OB+BtOLpJofmbGEGgvmwyCI9MwIDAQABAoIBACiARq2wkltjtcjs
        kFvZ7w1JAORHbEufEO1Eu27zOIlqbgyAcAl7q+/1bip4Z/x1IVES84/yTaM8p0go
        amMhvgry/mS8vNi1BN2SAZEnb/7xSxbflb70bX9RHLJqKnp5GZe2jexw+wyXlwaM
        +bclUCrh9e1ltH7IvUrRrQnFJfh+is1fRon9Co9Li0GwoN0x0byrrngU8Ak3Y6D9
        D8GjQA4Elm94ST3izJv8iCOLSDBmzsPsXfcCUZfmTfZ5DbUDMbMxRnSo3nQeoKGC
        0Lj9FkWcfmLcpGlSXTO+Ww1L7EGq+PT3NtRae1FZPwjddQ1/4V905kyQFLamAA5Y
        lSpE2wkCgYEAy1OPLQcZt4NQnQzPz2SBJqQN2P5u3vXl+zNVKP8w4eBv0vWuJJF+
        hkGNnSxXQrTkvDOIUddSKOzHHgSg4nY6K02ecyT0PPm/UZvtRpWrnBjcEVtHEJNp
        bU9pLD5iZ0J9sbzPU/LxPmuAP2Bs8JmTn6aFRspFrP7W0s1Nmk2jsm0CgYEAyH0X
        +jpoqxj4efZfkUrg5GbSEhf+dZglf0tTOA5bVg8IYwtmNk/pniLG/zI7c+GlTc9B
        BwfMr59EzBq/eFMI7+LgXaVUsM/sS4Ry+yeK6SJx/otIMWtDfqxsLD8CPMCRvecC
        2Pip4uSgrl0MOebl9XKp57GoaUWRWRHqwV4Y6h8CgYAZhI4mh4qZtnhKjY4TKDjx
        QYufXSdLAi9v3FxmvchDwOgn4L+PRVdMwDNms2bsL0m5uPn104EzM6w1vzz1zwKz
        5pTpPI0OjgWN13Tq8+PKvm/4Ga2MjgOgPWQkslulO/oMcXbPwWC3hcRdr9tcQtn9
        Imf9n2spL/6EDFId+Hp/7QKBgAqlWdiXsWckdE1Fn91/NGHsc8syKvjjk1onDcw0
        NvVi5vcba9oGdElJX3e9mxqUKMrw7msJJv1MX8LWyMQC5L6YNYHDfbPF1q5L4i8j
        8mRex97UVokJQRRA452V2vCO6S5ETgpnad36de3MUxHgCOX3qL382Qx9/THVmbma
        3YfRAoGAUxL/Eu5yvMK8SAt/dJK6FedngcM3JEFNplmtLYVLWhkIlNRGDwkg3I5K
        y18Ae9n7dHVueyslrb6weq7dTkYDi3iOYRW8HRkIQh06wEdbxt0shTzAJvvCQfrB
        jg/3747WSsf/zBTcHihTRBdAv6OmdhV4/dD5YBfLAkLrd+mX7iE=
        -----END RSA PRIVATE KEY-----
        """
      }
    }
    encodeJWT()
  }
  
  func refreshJWTSyntaxHighlight() {
    let components = inputTextView.string.components(separatedBy: ".")
    inputTextView.textStorage?.addAttributes(
      [
        NSAttributedString.Key.foregroundColor:
          #colorLiteral(red: 0.9843137255, green: 0.003921568627, blue: 0.3568627451, alpha: 1)
      ],
      range: .init(location: 0, length: components[0].count)
    )
    
    if components.count > 1 {
      inputTextView.textStorage?.addAttributes(
        [
          NSAttributedString.Key.foregroundColor: NSColor.textColor
        ],
        range: .init(location: components[0].count, length: 1)
      )
      inputTextView.textStorage?.addAttributes(
        [
          NSAttributedString.Key.foregroundColor:
            #colorLiteral(red: 0.8392156863, green: 0.2274509804, blue: 1, alpha: 1)
        ],
        range: .init(location: components[0].count + 1, length: components[1].count)
      )
    }
    if components.count > 2 {
      inputTextView.textStorage?.addAttributes(
        [
          NSAttributedString.Key.foregroundColor: NSColor.textColor
        ],
        range: .init(location: components[0].count + components[1].count + 1, length: 1)
      )
      inputTextView.textStorage?.addAttributes(
        [
          NSAttributedString.Key.foregroundColor:
            #colorLiteral(red: 0, green: 0.7254901961, blue: 0.9450980392, alpha: 1)
        ],
        range: .init(location: components[0].count + components[1].count + 2, length: components[2].count)
      )
    }
  }
  
  @IBAction func clipboardButtonAction(_ sender: Any) {
    inputTextView.selectAll(self)
    inputTextView.insertText(
      NSPasteboard.general.string(forType: .string) ?? "",
      replacementRange: .init(location: 0, length: inputTextView.string.count)
    )
    decodeJWT()
  }
  
  
  @IBAction func inputCopyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(inputTextView.string, forType: .string)
  }
  
  @IBAction func headerCopyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(headerTextView.string, forType: .string)
  }
  
  @IBAction func payloadCopyButtonAction(_ sender: Any) {
    NSPasteboard.general.clearContents()
    NSPasteboard.general.setString(payloadTextView.string, forType: .string)
  }
  
  override func ensureDefault(_ forceDefaults: Bool = false) {
    JWTViewController.ensureDefaults(forceDefaults)
  }
  
  static func ensureDefaults(_ forceDefaults: Bool = false) {
    AppState.ensureDefault("values.jwt-auto-detect-well-formed", true, forceDefaults)
  }
  
  @IBAction func settingButtonAction(_ sender: NSButton) {
    if settingViewController == nil {
      settingViewController = JWTSettingViewController(
        nibName: "JWTSettingViewController"
      )
    }
    
    let popover = NSPopover.init()
    popover.contentSize = .init(width: 300, height: 200)
    popover.behavior = .transient
    popover.animates = true
    popover.contentViewController = settingViewController
    popover.show(relativeTo: sender.bounds, of: sender, preferredEdge: .maxY)
  }
  
  @IBAction func clearButtonAction(_ sender: Any) {
    inputTextView.setStringRetrainUndo("")
    refreshStatus()
    refreshJWTSyntaxHighlight()
  }
}

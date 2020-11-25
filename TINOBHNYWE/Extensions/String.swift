//
//  String.swift
//  DevUtils2
//
//  Created by Tony Dinh on 5/23/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import JavaScriptCore

public class JSONParseError {
  var error: Int
  var offset: Int
  var length: Int
  
  enum ParseErrorCode: Int {
    case InvalidSymbol = 1
    case InvalidNumberFormat = 2
    case PropertyNameExpected = 3
    case ValueExpected = 4
    case ColonExpected = 5
    case CommaExpected = 6
    case CloseBraceExpected = 7
    case CloseBracketExpected = 8
    case EndOfFileExpected = 9
    case InvalidCommentToken = 10
    case UnexpectedEndOfComment = 11
    case UnexpectedEndOfString = 12
    case UnexpectedEndOfNumber = 13
    case InvalidUnicode = 14
    case InvalidEscapeCharacter = 15
    case InvalidCharacter = 16
  }
  
  init(object: NSObject) {
    self.error = object.value(forKey: "error") as? Int ?? 0
    self.offset = object.value(forKey: "offset") as? Int ?? 0
    self.length = object.value(forKey: "length") as? Int ?? 0
  }
  
  func toString() -> String {
    switch self.error {
    case ParseErrorCode.InvalidSymbol.rawValue: return "Invalid symbol at offset: \(self.offset)"
    case ParseErrorCode.InvalidNumberFormat.rawValue: return "Invalid number format at offset: \(self.offset)"
    case ParseErrorCode.PropertyNameExpected.rawValue: return "Property name expected at offset: \(self.offset)"
    case ParseErrorCode.ValueExpected.rawValue: return "Value expected at offset: \(self.offset)"
    case ParseErrorCode.ColonExpected.rawValue: return "Colon expected at offset: \(self.offset)"
    case ParseErrorCode.CommaExpected.rawValue: return "Comma expected at offset: \(self.offset)"
    case ParseErrorCode.CloseBraceExpected.rawValue: return "Close brace expected at offset: \(self.offset)"
    case ParseErrorCode.CloseBracketExpected.rawValue: return "Close bracket expected at offset: \(self.offset)"
    case ParseErrorCode.EndOfFileExpected.rawValue: return "End of file expected at offset: \(self.offset)"
    case ParseErrorCode.InvalidCommentToken.rawValue: return "Invalid comment token at offset: \(self.offset)"
    case ParseErrorCode.UnexpectedEndOfComment.rawValue: return "Unexpected end of comment at offset: \(self.offset)"
    case ParseErrorCode.UnexpectedEndOfString.rawValue: return "Unexpected end of string at offset: \(self.offset)"
    case ParseErrorCode.UnexpectedEndOfNumber.rawValue: return "Unexpected end of number at offset: \(self.offset)"
    case ParseErrorCode.InvalidUnicode.rawValue: return "Invalid unicode at offset: \(self.offset)"
    case ParseErrorCode.InvalidEscapeCharacter.rawValue: return "Invalid escape character at offset: \(self.offset)"
    case ParseErrorCode.InvalidCharacter.rawValue: return "Invalid character at offset: \(self.offset)"
    default:  return "Unknown parse error"
    }
  }
}

extension String {
  func encodeUrl() -> String? {
    return self.addingPercentEncoding(withAllowedCharacters: NSCharacterSet.urlUserAllowed)
  }
  
  func decodeUrl() -> String? {
    return self.removingPercentEncoding?.replacingOccurrences(of: "+", with: " ")
  }
  /**
   Returns a new string made from the receiver by replacing characters which are
   reserved in a URI query with percent encoded characters.
   
   The following characters are not considered reserved in a URI query
   by RFC 3986:
   
   - Alpha "a...z" "A...Z"
   - Numberic "0...9"
   - Unreserved "-._~"
   
   In addition the reserved characters "/" and "?" have no reserved purpose in the
   query component of a URI so do not need to be percent escaped.
   
   - Returns: The encoded string, or nil if the transformation is not possible.
   */
  
  public func stringByAddingPercentEncodingForRFC3986() -> String? {
    let unreserved = "-._~/?"
    let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
    allowedCharacterSet.addCharacters(in: unreserved)
    return addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
  }
  
  
  /**
   Returns a new string made from the receiver by replacing characters which are
   reserved in HTML forms (media type application/x-www-form-urlencoded) with
   percent encoded characters.
   
   The W3C HTML5 specification, section 4.10.22.5 URL-encoded form
   data percent encodes all characters except the following:
   
   - Space (0x20) is replaced by a "+" (0x2B)
   - Bytes in the range 0x2A, 0x2D, 0x2E, 0x30-0x39, 0x41-0x5A, 0x5F, 0x61-0x7A
     (alphanumeric + "*-._")
   - Parameter plusForSpace: Boolean, when true replaces space with a '+'
   otherwise uses percent encoding (%20). Default is false.
   
   - Returns: The encoded string, or nil if the transformation is not possible.
   */

  public func stringByAddingPercentEncodingForFormData(plusForSpace: Bool=false) -> String? {
    let unreserved = "*-._"
    let allowedCharacterSet = NSMutableCharacterSet.alphanumeric()
    allowedCharacterSet.addCharacters(in: unreserved)
    
    if plusForSpace {
        allowedCharacterSet.addCharacters(in: " ")
    }
    
    var encoded = addingPercentEncoding(withAllowedCharacters: allowedCharacterSet as CharacterSet)
    if plusForSpace {
        encoded = encoded?.replacingOccurrences(of: " ", with: "+")
    }
    return encoded
  }
  
  public func pretifyJSON(format: Any? = nil) -> String? {
    let context = JSContext()!
    context.setObject(format, forKeyedSubscript: "format" as NSString)
    context.setObject(self, forKeyedSubscript: "json" as NSString)
    let result = context.evaluateScript("JSON.stringify(JSON.parse(json), null, format)")
    return result?.toString()
  }
  
  // TODO: move this to JSONTextView
  public func pretifyJSONv2(format: Int? = nil, spaces: Bool = true, allowWeakJSON: Bool = false, errors: inout [JSONParseError]) -> String? {
    let context = JSContext()!
    context.setObject(format, forKeyedSubscript: "tabSize" as NSString)
    context.setObject(spaces, forKeyedSubscript: "useSpace" as NSString)
    context.setObject(self, forKeyedSubscript: "input" as NSString)
    context.setObject(allowWeakJSON, forKeyedSubscript: "allowWeakJSON" as NSString)
    context.evaluateScript(JSHelpers.readJSONFormatter())

    var result: JSValue?
    
    if format == nil && spaces {
      result = context.evaluateScript(
        """
        var result = input;
        try {
          result = JSON.stringify(JSON.parse(input));
        } catch { /* It's ok to skip error here, we parse error later. */ }
        result;
        """
      )
    } else {
      // Return best effort formatted JSON
      result = context.evaluateScript(
        """
        var result = applyEditOperations(
          input,
          jsonFormatter.format(
            input,
            undefined,
            { insertSpaces: useSpace, tabSize: tabSize || 2 }
          )
        );
        result;
        """
      )
    }
    
    // Get syntax errors
    if let errs = context.evaluateScript("""
      var errors = [];
      json.parse(
        result,
        errors,
        { allowTrailingComma: allowWeakJSON, disallowComments: !allowWeakJSON }
      );
      errors;
    """) {
      if let objArray = errs.toArray() as? [NSObject] {
        (objArray.map({ (obj) -> JSONParseError in
          return JSONParseError.init(object: obj)
        })).forEach { (e) in
          errors.append(e)
        }
      }
    }
    
    return result?.toString()
  }
  
  var unescaped: String {
    let entities = ["\0", "\t", "\n", "\r", "\"", "\'"]
    
    let parts = self.components(separatedBy: "\\".debugDescription.dropFirst().dropLast()).map { (part) -> String in
      var current = part
      for entity in entities {
        let descriptionCharacters = entity.debugDescription.dropFirst().dropLast()
        let description = String(descriptionCharacters)
        current = current.replacingOccurrences(of: description, with: entity)
      }
      return current
    }
    
    return parts.joined(separator: "\\")
  }

  func fromBase64(_ encoding: String.Encoding = .utf8) -> String? {
    // The ==== part is to make the decoding process easier by providing fake padding
    // Remove all newlines and spaces
    let string = "\(self)====".replacingOccurrences(of: "\\s*", with: "", options: .regularExpression)
    guard let data = Data(base64Encoded: string) else {
      return nil
    }
    
    return String(data: data, encoding: encoding)
  }
  
  func toBase64(_ encoding: String.Encoding = .utf8) -> String? {
    return self.data(using: encoding)?.base64EncodedString()
  }
  
  init?(htmlEncodedString: String) {
    
    guard let data = htmlEncodedString.data(using: .utf8) else {
      return nil
    }
    
    let options: [NSAttributedString.DocumentReadingOptionKey: Any] = [
      .documentType: NSAttributedString.DocumentType.html,
      .characterEncoding: String.Encoding.utf8.rawValue
    ]
    
    guard let attributedString = try? NSAttributedString(data: data, options: options, documentAttributes: nil) else {
      return nil
    }
    
    self.init(attributedString.string)
    
  }
  
  var isInt: Bool {
      return Int(self) != nil
  }
}

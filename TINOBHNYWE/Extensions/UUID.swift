//
//  UUID.swift
//  DevUtils2
//
//  Created by Tony Dinh on 9/30/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation
import CommonCrypto

public extension UUID {
  
  init?(uuidVersion: Int, namespace: UUID?, name: String) {
    guard let nameData = name.data(using: .utf8) else { return nil }
    guard let namespaceInBytes = namespace?.uuid else { return nil }
    
    var tmpNamespaceArray = namespaceInBytes
    let namespaceInArray = UnsafeBufferPointer(start: &tmpNamespaceArray.0, count: MemoryLayout.size(ofValue: tmpNamespaceArray))
    let namespaceData = Data(buffer: namespaceInArray)
    let unifiedData = namespaceData + nameData
    
    var digestArray = [UInt8](repeating: 0x00, count: Int(max(CC_MD5_DIGEST_LENGTH, CC_SHA1_DIGEST_LENGTH)))
    
    switch uuidVersion {
    case 3:
      _ = unifiedData.withUnsafeBytes { unsafeDataPointer in
        CC_MD5(unsafeDataPointer.baseAddress, CC_LONG(unifiedData.count), &digestArray)
      }
    case 5:
      _ = unifiedData.withUnsafeBytes { unsafeDataPointer in
        CC_SHA1(unsafeDataPointer.baseAddress, CC_LONG(unifiedData.count), &digestArray)
      }
    default:
      return nil
    }
    
    let digestTuple = (
      digestArray[0], digestArray[1], digestArray[2], digestArray[3], digestArray[4], digestArray[5],
      UInt8(uuidVersion * 0x10) + digestArray[6] % 0x10,
      digestArray[7],
      UInt8(0x80) + digestArray[8] % 0x40,
      digestArray[9], digestArray[10], digestArray[11], digestArray[12], digestArray[13], digestArray[14], digestArray[15]
    )
    // since MD5  has fixed length of 128 = 8 * 16 bit, access to digestArray[0...15] is guaranteed.
    // since SHA1 has fixed length of 160 = 8 * 20 bit, access to digestArray[0...19] is guaranteed.
    self = UUID(uuid: digestTuple)
  }
  
  // NodeId extracts the node id from the receiver UUID.
  var node: String {
    guard let lastPart = self.uuidString.split(separator: "-").last else {
      return ""
    }
    
    return String(lastPart.enumerated().map { $0 > 0 && $0 % 2 == 0 ? [":", $1] : [$1]}.joined()).lowercased()
  }
  
  var rawContents: String {
    let hex = self.uuidString.replacingOccurrences(of: "-", with: "")
    
    return String(hex.enumerated().map { $0 > 0 && $0 % 2 == 0 ? [":", $1] : [$1]}.joined()).lowercased()
  }
  
  var time: Date {
    let components = uuidString.split(separator: "-")
    
    let hex = String(components[2].dropFirst()) + components[1] + components[0]
    // 100-nanoseconds intervals
    let interval = Int(hex, radix: 16)!
    // -12219292800000 relative milliseconds to 1970
    let milliSeconds = TimeInterval(interval / 10000) - 12219292800000
    return Date.init(timeIntervalSince1970: milliSeconds / 1000)
  }
  
  var clockId: Int {
    let components = uuidString.split(separator: "-")
    
    let hex = components[3]
    // 100-nanoseconds intervals
    let clockAndReserved = Int(hex, radix: 16)!
    // Remove the first 2 significant bits 0011 1111 1111 1111
    let clock = clockAndReserved & 0x3FFF
    return clock
  }
  
  var variant: String {
    let variantChar = String(Array(self.uuidString.lowercased())[19])
    var variant = ""
    
    if "01234567".contains(variantChar) {
      variant = "Reserved (NCS backward compatible)"
    } else if "89ab".contains(variantChar) {
      variant = "Standard (DCE 1.1, ISO/IEC 11578:1996)"
    } else if "cd".contains(variantChar) {
      variant = "Reserved (Microsoft GUID)"
    } else if "e".contains(variantChar) {
      variant = "Reserved (future use)"
    } else {
      variant = "Unknown / Invalid"
    }
    return variant
  }
  
  var versionChar: String {
    return String(Array(self.uuidString)[14])
  }
  
  var version: String {
    var version = ""
    
    if versionChar == "1" {
      version = "1 (time and node based)"
    } else if versionChar == "2" {
      version = "2 (reserved)"
    } else if versionChar == "3" {
      version = "3 (name based, MD5 hashed)"
    } else if versionChar == "4" {
      version = "4 (random)"
    } else if versionChar == "5" {
      version = "5 (name based, SHA-1 hashed)"
    } else {
      version = "(unknown)"
    }
    return version
  }
  
  struct namespace {
    // Defined in RFC4122  https://tools.ietf.org/html/rfc4122#appendix-C
    static let DNS = UUID(uuidString: "6ba7b810-9dad-11d1-80b4-00c04fd430c8")!
    static let URL = UUID(uuidString: "6ba7b811-9dad-11d1-80b4-00c04fd430c8")!
    static let OID = UUID(uuidString: "6ba7b812-9dad-11d1-80b4-00c04fd430c8")!
    static let X500 = UUID(uuidString: "6ba7b814-9dad-11d1-80b4-00c04fd430c8")!
  }
}

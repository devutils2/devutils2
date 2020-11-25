//
//  Array.swift
//  DevUtils2
//
//  Created by Tony Dinh on 10/15/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

extension Array {
  subscript (safe index: Index) -> Element? {
    return 0 <= index && index < count ? self[index] : nil
  }
  
  mutating func move(from start: Index, to end: Index) {
    guard (0..<count) ~= start, (0...count) ~= end else { return }
    if start == end { return }
    let targetIndex = start < end ? end - 1 : end
    insert(remove(at: start), at: targetIndex)
  }
  
  mutating func move(with indexes: IndexSet, to toIndex: Index) {
    let movingData = indexes.map{ self[$0] }
    let targetIndex = toIndex - indexes.filter{ $0 < toIndex }.count
    for (i, e) in indexes.enumerated() {
      remove(at: e - i)
    }
    insert(contentsOf: movingData, at: targetIndex)
  }
}

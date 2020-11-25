//
//  Date.swift
//  TINOBHNYWE
//
//  Created by Tony Dinh on 5/17/20.
//  Copyright © 2020 Tony Dinh. All rights reserved.
//

import Foundation

extension Date {
  func timeAgo() -> String {
    let distance = Int(
      Date.init().timeIntervalSince1970 -
        self.timeIntervalSince1970
    )
    
    let relative = distance < 0 ? "from now" : "ago"
    var secondsLeft = abs(distance)
    
    // Roughly estimated using 365 days per year
    let years = secondsLeft / (365 * 86400)
    secondsLeft = secondsLeft % (365 * 86400)
    // Roughly estimated using 30days per month
    let months = secondsLeft / (30 * 86400)
    secondsLeft = secondsLeft % (30 * 86400)
    let days = secondsLeft / 86400
    secondsLeft = secondsLeft % 86400
    let hours = secondsLeft / 3600
    secondsLeft = secondsLeft % 3600
    let minutes = secondsLeft / 60
    secondsLeft = secondsLeft % 60
    let seconds = secondsLeft
    
    var result = "\(seconds)sec \(relative)"
    
    if minutes > 0 {
      result = "\(minutes)min " + result
    }
    
    if hours > 0 {
      result = "\(hours)hr " + result
    }
    
    if days > 0 {
      result = "\(days)d " + result
    }
    
    if months > 0 {
      result = "\(months)mo " + result
    }
    
    if years > 0 {
      result = "\(years)yr " + result
    }
    
    return result
  }
}

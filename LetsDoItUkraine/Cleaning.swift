//
//  Cleaning.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct Cleaning : CustomStringConvertible {
  var ID: String
  var address: String
  var pictures: [URL]?
  var datetime: Date?
  var summary: String?
  var isActive: Bool
  var cooridnate: CLLocationCoordinate2D
  
  var description: String {
    return "CLEANING: \(ID)\n" +
            "lat: \(cooridnate.latitude) lon: \(cooridnate.longitude)\n" +
            (isActive ? "Active" : "Not active")
  }
  
  init() {
    ID = ""
    cooridnate = CLLocationCoordinate2D()
    isActive = false
    address = ""
  }
}

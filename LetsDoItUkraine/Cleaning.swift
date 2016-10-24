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
  var coordinate: CLLocationCoordinate2D
  
  var description: String {
    return "CLEANING: \(ID)\n" +
            "lat: \(coordinate.latitude) lon: \(coordinate.longitude)\n" +
            (isActive ? "Active" : "Not active")
  }
  
  init() {
    ID = ""
    coordinate = CLLocationCoordinate2D()
    isActive = false
    address = ""
  }
}

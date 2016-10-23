//
//  RecyclePoint.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct RecyclePoint : CustomStringConvertible {
    var ID: String
    var title: String
    var phone: String?
    var website: String?
    var logo: URL?
    var picture: URL?
    var coordinate: CLLocationCoordinate2D
    var address: String
    var schedule: String?
    var summary: String?
    var categories: Set<String>
  
  var description: String {
    return "RECYCLE POINT: - \(ID) - \(title)\n" +
    "location: \(coordinate.latitude), \(coordinate.longitude)\n" +
    "\(categories)"
  }
  
  init() {
    ID = "[no id]"
    title = "[no title]"
    address = "[no address]"
    categories = []
    coordinate = CLLocationCoordinate2D()
  }
}

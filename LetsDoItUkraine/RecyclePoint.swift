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
    var location: CLLocationCoordinate2D
    var adress: String?
    var schedule: String?
    var summary: String?
    var categories: [String]
  
  var description: String {
    return "RECYCLE POINT: - \(ID) - \(title)\n" +
    "location: \(location.latitude), \(location.longitude)\n" +
    "\(categories)"
  }
}

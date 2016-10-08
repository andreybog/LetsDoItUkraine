//
//  Cleaning.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct Cleaning : CustomDebugStringConvertible {
  var ID: String
  var adress: String?
  var pictures: [[String : String]]?
  var datetime: String?
  var description: String?
  var isActive: Bool
  var cooridnate: CLLocationCoordinate2D
  
  var debugDescription: String {
    return "CLEANING: \(ID)\n" +
            "lat: \(cooridnate.latitude) lon: \(cooridnate.longitude)\n" +
            (isActive ? "Active" : "Not active")
  }
  
  
  init(withId newId:String, data: [String: AnyObject]) {
    ID = newId
    adress = data["address"] as? String
    pictures = data["pictures"] as? [[String : String]]
    datetime = data["datetime"] as? String
    description = data["description"] as? String
    isActive = data["active"] as! Bool
    cooridnate = CLLocationCoordinate2D(latitude: data["latitude"] as! Double,
                                        longitude: data["longitude"] as! Double)
    
  }
  
  
}

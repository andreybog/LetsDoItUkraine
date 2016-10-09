//
//  RecyclePoint.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct RecyclePoint : DictionaryInitable, CustomDebugStringConvertible {
    var ID: String
    var title: String
    var phone: String?
    var website: String?
    var logo: NSURL?
    var picture: NSURL?
    var location: CLLocationCoordinate2D
    var adress: String?
    var schedule: String?
    var summary: String?
    var categories: [String]
  
  var debugDescription: String {
    return "RECYCLE POINT: - \(ID) - \(title)\n" +
    "location: \(location.latitude), \(location.longitude)\n" +
    "\(categories)"
  }
  
  init(withId newId:String, data: [String: AnyObject]) {
    ID = newId
    title = data["title"] as! String
    phone = data["phone"] as? String
    website = data["website"] as? String
    adress = data["adress"] as? String
    schedule = data["schedule"] as? String
    summary = data["summary"] as? String
    
    location = CLLocationCoordinate2D(latitude: data["latitude"] as! Double ,
                                      longitude: data["longitude"] as! Double)
    
    if let logoDict = data["logo"] as? [String:AnyObject],
        let urlString = logoDict["url"] as? String {
      logo = NSURL(string: urlString)
    }
    
    if let picDict = data["picture"] as? [String:AnyObject],
      let urlString = picDict["url"] as? String {
      picture = NSURL(string: urlString)
    }
    
    categories = data["categories"] as! [String]
  }
}

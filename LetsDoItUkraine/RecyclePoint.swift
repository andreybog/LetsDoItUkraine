//
//  RecyclePoint.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct RecyclePoint {
    var ID: Int
    var title: String
    var phone: String
    var website: NSURL?
    var logo: NSURL?
    var picture: NSURL?
    var location: CLLocation
    var adress: String
    var schedule: String
    var summary: String?
    var categories: [RecyclePoint]
    
    init(data: [String: AnyObject]) {
        ID = data["id"] as! Int
        title = data["title"] as! String
        phone = data["phone"] as! String
        website = NSURL(string:data["title"] as! String)
        logo = NSURL(string:data["logo"] as! String)
        picture = NSURL(string:data["picture"] as! String)
        location = CLLocation(latitude: data["lat"] as! Double, longitude: data["long"] as! Double)
        adress = data["adress"] as! String
        schedule = data["schedule"] as! String
        summary = data["summary"] as? String
        categories = data["categories"] as! [RecyclePoint]
    }
}

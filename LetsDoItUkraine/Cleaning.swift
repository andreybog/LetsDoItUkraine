//
//  Cleaning.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

struct CleaningMetadata {
    var ID: String!
    var userRole: UserRole!
    var startAt: Date!
}

struct Cleaning : CustomStringConvertible {
    var ID: String
    var address: String
    var pictures: [URL]?
    var createdAt: Date!
    var startAt: Date!
    var summary: String?
    var coordinate: CLLocationCoordinate2D
    var coordinatorsIds: [String]?
    var cleanersIds: [String]?
    
    
    var description: String {
        return "CLEANING: \(ID)\n" +
            "lat: \(coordinate.latitude) lon: \(coordinate.longitude)\n"
    }
    
    init() {
        ID = ""
        address = "[no address]"
        coordinate = CLLocationCoordinate2D()
        createdAt = Date(timeIntervalSince1970: 0)
        startAt = Date(timeIntervalSince1970: 0)
    }
}

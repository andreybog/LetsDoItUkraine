//
//  DirectionManager.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/15/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

class Direction {
    func getDirectionURLTo(Location destination: CLLocationCoordinate2D) -> URL? {
        let mainURL = "https://maps.google.com/?"
        let startLocation = CLLocationManager().location?.coordinate
        let params = "saddr=\(startLocation)&daddr=\(destination)"
        let string = "\(mainURL)\(params)"
        let urlString = "\(string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let url = URL(string: urlString)
        return url
    }
}

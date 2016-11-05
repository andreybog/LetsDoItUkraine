//
//  StreetViewFormatter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/2/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

class StreetViewFormatter{
    
    func setStreetViewImageWith(coordinates: String) -> String {
        let mainURL = "https://maps.googleapis.com/maps/api/streetview?"
        let size = "300x300"
        let location = "\(coordinates.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let urlString = "\(mainURL)size=\(size)&location=\(location)&key=\(kGoogleStreetViewAPIKey)"
        return urlString
    }
}

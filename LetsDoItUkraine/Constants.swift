//
//  Constants.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/15/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

let kGoogleStreetViewAPIKey = "AIzaSyA1TDXPwLbdmyj65TgG3hrUrxZDAH79Cg8"
let kGoogleMapsSDKAPIKey = "AIzaSyBET-S0Lg7dOJTPivUa_YKYqKkjzEaiw1o"
let kGooglePlacesAPIKey = "AIzaSyB14eOlQa6V3g4lRaxYfROITTbWB5AvOSA"
let kGoogleMapsGeocodingAPIKey = "AIzaSyBcX36PWtVP6_4wFVDvxbFnsv_olOrfy4A"


enum NotificationsNames: String {
    case currentUserProfileChanged = "userProfileChanged"
    
    var name: Notification.Name {
        return Notification.Name(self.rawValue)
    }
}

enum ImageStoragePath: String {
    case news = "News_images"
    case cleanings = "Cleanings_images"
    
    var path: String {
        return self.rawValue
    }
}

enum MainTabBarItemsIndexes: Int {
    case profile
    case map
    case news
    case cleaningCreation
 
    var index: Int {
        return self.rawValue
    }
}

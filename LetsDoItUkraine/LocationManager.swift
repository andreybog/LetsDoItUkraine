//
//  LocationManager.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

class LocationManager : NSObject, CLLocationManagerDelegate {
    
    let manager = CLLocationManager()
    
    func determineAutorizationStatus(handler: @escaping (_:String) -> Void){
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
            handler("Requesting When In Use")
        case .denied:
            handler("Denied")
        case .authorizedWhenInUse:
            self.startUpdatingLocation()
            handler("Started Updating")
        default:
            print("Default")
        }
    }
    
    func startUpdatingLocation() {
        manager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        determineAutorizationStatus {_ in }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        if currentLocation.horizontalAccuracy < manager.desiredAccuracy {
            manager.stopUpdatingLocation()
        }
    }
    
    
    
}

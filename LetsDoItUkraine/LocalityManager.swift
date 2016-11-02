//
//  LocalityManager.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/2/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

class LocalityManager {
    
    func searchForSublocalityWith(coordinates: CLLocationCoordinate2D, handler: @escaping (_ districtName:String) -> Void){
        let coordinateString = "\(coordinates.latitude), \(coordinates.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinateString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&language=ru&key=\(kGoogleMapsGeocodingAPIKey)"
        let url = URL(string: "\(urlString)")
        let task = URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            if error != nil{
                print(error!)
            }else {
                do {
                    if data != nil{
                        var districtName = ""
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                        let dictionaryResults = dic["results"] as! [[String:AnyObject]]
                        let addressComponents = dictionaryResults.first?["address_components"] as! [[String:AnyObject]]
                        var isComponentTypeAvailable = false
                        let arrayOfLocalities = ["sublocality", "locality", "administrative_area_level_2", "administrative_area_level_1"]
                        for locality in arrayOfLocalities {
                            for component in addressComponents {
                                let componentTypes = component["types"] as! [String]
                                if componentTypes.contains(locality){
                                    districtName = component["long_name"] as! String
                                    isComponentTypeAvailable = true
                                    break
                                }
                            }
                            if isComponentTypeAvailable{
                                break
                            }
                        }
                        handler(districtName)
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }
    
}

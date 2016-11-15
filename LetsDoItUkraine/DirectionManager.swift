//
//  DirectionManager.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/15/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

class DirectionManager {
    func getDirectionURLTo(Location destination: CLLocationCoordinate2D) -> URL? {
        let mainURL = "https://maps.google.com/?"
        let startLocation = CLLocationManager().location?.coordinate
        let params = "saddr=\(startLocation)&daddr=\(destination)"
        let string = "\(mainURL)\(params)"
        let urlString = "\(string.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let url = URL(string: urlString)
        return url
    }
    
    func getRouteDataWith(StartPoint startPoint: CLLocationCoordinate2D, andDestinationPoint destinationPoint: CLLocationCoordinate2D, withHandler handler: @escaping(_ numbers:(String,String,String)) -> Void) {
        let baseURL = "https://maps.googleapis.com/maps/api/directions/json?"
        let origin = "origin=\(startPoint.latitude),\(startPoint.longitude)"
        let destination = "destination=\(destinationPoint.latitude),\(destinationPoint.longitude)"
        let stringURL = "\(baseURL)\(origin)&\(destination)&key=\(kGoogleDirectionsAPIKey)"
        self.getDataWith(URL: stringURL, withHandler: { routeString, distance, duration in
            handler((routeString, distance, duration))
        })
    }
    
    private func getDataWith(URL string: String,withHandler handler: @escaping (_ route:String, _ distance :String,_ andDuration:String) -> Void){
        let url = URL(string: string)
        if url != nil{
            let task = URLSession.shared.dataTask(with: url!, completionHandler: { (data, responce, error) in
                if error != nil{
                    print(error!)
                } else {
                    if data != nil{
                        var dic = Dictionary<String, Any>()
                        do {
                            dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! Dictionary<String, Any>
                        } catch {
                            print("error parsing JSON")
                        }
                        let routes = dic["routes"]! as! Array<[String:Any]>
                        let selectedRoute = routes[0] 
                        let route = selectedRoute["overview_polyline"] as! [String:String]
                        let overviewRoute = route["points"]!
                        let numbers = self.findDistanceAndTimeWith(Route: selectedRoute)
                        handler(overviewRoute, numbers.0, numbers.1)
                    }
                }
            })
            task.resume()
        }
    }
    private func findDistanceAndTimeWith(Route route: [String:Any]) -> (String, String){
        let legs = route["legs"] as! Array<Dictionary<String,AnyObject>>
        
        var totalDistanceInMeters = 0
        var totalDurationInSeconds = 0
        
        for leg in legs{
            totalDistanceInMeters += (leg["distance"] as! Dictionary<String,AnyObject>)["value"] as! Int
            totalDurationInSeconds += (leg["duration"] as! Dictionary<String,AnyObject>)["value"] as! Int
        }
        let distanceInKilometers : Double = Double(totalDistanceInMeters/1000)
        let totalDistance = "Общая длина маршрута: \(distanceInKilometers) КМ"
        
        let minutes = totalDurationInSeconds / 60
        let hours = minutes / 60
        let days = hours / 24
        let remainingHours = hours % 24
        let remainingMinutes = minutes % 60
        let remainingSeconds = totalDurationInSeconds % 60
        let totalDuration = "Длительность: \(days) д, \(remainingHours) ч, \(remainingMinutes) мин, \(remainingSeconds) сек"
        
        return (totalDistance,totalDuration)
    }
}

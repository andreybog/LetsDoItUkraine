//
//  CleaningsMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

protocol CleaningsMapPresentDelegate {
    func updateUI()
}

class CleaningsMapPresenter {
    
    private let locationManager = LocationManager()
    var delegate : CleaningsMapPresentDelegate!
    
    private let cleaningsManager = CleaningsManager.defaultManager
    private let usersManager = UsersManager.defaultManager
    
    var cleaningsArray = [Cleaning]()
    var cleaningsCoordinators:[[User]]!
    var cleaningsDistricts = [String]()
    
    init() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        addCleaningsObservers()
    }
    
    deinit {
        removeCleaningsObservers()
    }
    
    func loadCleanings() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        if cleaningsArray.count > 0 {
            self.fillMemberAndDistrictArrays()
        }
        delegate.updateUI()
    }
    
    
    private func fillMemberAndDistrictArrays() {
        for (index, cleaning) in cleaningsArray.enumerated() {
            if cleaning.coordinatorsIds != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { users in
                    self.cleaningsCoordinators[index] = users
                })
            }
            searchForSublocalityWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)", handler: { (districtName) in
                self.cleaningsDistricts[index] = districtName
            })
        }
    }
    
    private func searchForSublocalityWith(coordinates: String, handler: @escaping (_:String) -> Void){
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&language=ru&key=\(kGoogleMapsGeocodingAPIKey)"
        let url = URL(string: "\(urlString)")
        let task = URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            if error != nil{
                print(error)
            }else {
                do {
                    if data != nil{
                        var districtName = ""
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                        let dictionaryResults = dic["results"] as! [[String:AnyObject]]
                        let addressComponents = dictionaryResults.first?["address_components"] as! [[String:AnyObject]]
                        for component in addressComponents {
                            let componentTypes = component["types"] as! [String]
                            if componentTypes.contains("sublocality"){
                                districtName = component["long_name"] as! String
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
    
    private func addCleaningsObservers() {
        cleaningsManager.retainObserver()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCleaningsWith),
                                               name: kCleaningsManagerCleaningModifyNotification,
                                               object: nil)
    }
    
    private func removeCleaningsObservers() {
        cleaningsManager.releaseObserver()
        NotificationCenter.default.removeObserver(self, name: kCleaningsManagerCleaningModifyNotification, object: nil)
    }
    
    @objc func updateCleaningsWith(notification:Notification) {
        loadCleanings()
    }
    
    func determineAutorizationStatus(handler: @escaping (_: String) -> Void) {
        self.locationManager.determineAutorizationStatus { (status) in
            handler(status)
        }
    }

}

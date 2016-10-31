//
//  CleaningsMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

//protocol CleaningView {
//    var district: String! { get set }
//    var address: String! {get set}
//    var coordinator : String! {get set}
//    var participants : String! {get set}
//}
//
//extension CleaningsMapCollectionViewCell: CleaningView {
//
//    var district: String! {
//        get {
//            return self.districtLabel.text ?? ""
//        }
//        set {
//            self.districtLabel.text = newValue
//        }
//    }
//    var address: String! {
//        get{
//            return self.addressLabel.text ?? ""
//        }
//        set {
//            self.districtLabel.text = newValue
//        }
//    }
//    var coordinator : String! {
//        get{
//            return self.coordinatorNameLabel.text ?? ""
//        }
//        set {
//            self.coordinatorNameLabel.text = newValue
//        }
//    }
//    var participants : String! {
//        get{
//            return self.participantsNumberLabel.text ?? ""
//        }
//        set {
//            self.participantsNumberLabel.text = newValue
//        }
//    }
//}

protocol CleaningsMapPresentDelegate {
    func didUpdateCleanings()
//    func fillCleaningShortDetails(cleaning:CleaningView, index: Int)
}

class CleaningsMapPresenter {
    
    private let locationManager = LocationManager()
    var delegate : CleaningsMapPresentDelegate!
    
    private let cleaningsManager = CleaningsManager.defaultManager
    private let usersManager = UsersManager.defaultManager
    
    var cleaningsArray = [Cleaning]()
    var cleaningsCoordinators:[[User]]!
    var cleaningsDistricts = [String]()
    var streetViewImages = [URL?]()
    
    init() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        self.streetViewImages = [URL?](repeatElement(nil, count: cleaningsArray.count))
        addCleaningsObservers()
    }

    
    deinit {
        removeCleaningsObservers()
    }
    
    func loadCleanings() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        self.streetViewImages = [URL?](repeatElement(nil, count: cleaningsArray.count))
        if cleaningsArray.count > 0 {
            self.fillMemberDistrictArraysAndStreetViewUrl()
        }
        if delegate != nil {
            delegate.didUpdateCleanings()
        }
    }

    private func fillMemberDistrictArraysAndStreetViewUrl() {
        for (index, cleaning) in cleaningsArray.enumerated() {
            if cleaning.coordinatorsIds != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { users in
                    self.cleaningsCoordinators[index] = users
                })
            }
            searchForSublocalityWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)", handler: { (districtName) in
                self.cleaningsDistricts[index] = districtName
            })
            setStreetViewImageWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)", handler: { (urlString) in
                let url = URL(string: urlString)
                if url != nil {
                    self.streetViewImages[index] = url!
                } else {
                    self.streetViewImages[index] = nil
                }
            })
        }
    }
    
    private func setStreetViewImageWith(coordinates: String, handler: @escaping (_: String) -> Void){
        let mainURL = "https://maps.googleapis.com/maps/api/streetview?"
        let size = "300x300"
        let location = "\(coordinates.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)"
        let urlString = "\(mainURL)size=\(size)&location=\(location)&key=\(kGoogleStreetViewAPIKey)"
        handler(urlString)
    }

    
    private func searchForSublocalityWith(coordinates: String, handler: @escaping (_:String) -> Void){
        
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?latlng=\(coordinates.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)!)&language=ru&key=\(kGoogleMapsGeocodingAPIKey)"
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

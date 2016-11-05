//
//  CleaningsMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

protocol CleaningsCollectionViewFillingProtocol {
    var district: String! { get set }
    var address: String! {get set}
    var distance : String! {get set}
    var coordinator : String! {get set}
    var participants : String! {get set}
}

extension CleaningsMapCollectionViewCell : CleaningsCollectionViewFillingProtocol {
    var district : String! {
        get{
            return self.districtLabel.text
        }
        set{
            self.districtLabel.text = newValue
        }
    }
    var address: String! {
        get{
            return self.addressLabel.text
        }
        set {
            self.addressLabel.text = newValue
        }
    }
    var distance: String! {
        get{
            return self.distanceLabel.text
        }
        set{
            self.distanceLabel.text = newValue
        }
    }
    var coordinator: String! {
        get{
            return self.coordinatorNameLabel.text
        }
        set{
            self.coordinatorNameLabel.text = newValue
        }
    }
    var participants: String! {
        get{
            return self.participantsNumberLabel.text
        }
        set{
            self.participantsNumberLabel.text = newValue
        }
    }
}

protocol CleaningsMapPresentDelegate {
    func didUpdateCleanings()
}

class CleaningsMapPresenter {
    
    var delegate : CleaningsMapPresentDelegate!
    private let localityManager = LocalityManager()
    
    private let cleaningsManager = CleaningsManager.defaultManager
    private let usersManager = UsersManager.defaultManager
    
    private var cleaningsArray = [Cleaning]()
    private var cleaningsCoordinators:[[User]]!
    private var cleaningsDistricts = [String]()
    private var streetViewImages = [URL?]()
    private var cleaningDistances = [Double?]()
    
    init() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        self.streetViewImages = [URL?](repeatElement(nil, count: cleaningsArray.count))
        self.cleaningDistances = [Double?](repeatElement(nil, count: cleaningsArray.count))
    }
    
    deinit {
        removeCleaningsObservers()
    }
    
    private func loadCleanings() {
        DispatchQueue.global().async {
            self.cleaningsArray = [Cleaning](self.cleaningsManager.activeCleanings.values)
            self.cleaningsCoordinators = [[User]](repeatElement([], count: self.cleaningsArray.count))
            self.cleaningsDistricts = [String](repeatElement("", count: self.cleaningsArray.count))
            self.streetViewImages = [URL?](repeatElement(nil, count: self.cleaningsArray.count))
            self.fillMemberDistrictArraysAndStreetViewUrl()
            if self.delegate != nil {
                self.delegate.didUpdateCleanings()
            }
        }
    }
    
    func getCoordinatesBy(ID number: String) -> (CLLocationCoordinate2D?, Int?){
        for (index,point) in cleaningsArray.enumerated(){
            if point.ID == number{
                return (point.coordinate, index)
            }
        }
        return (nil, nil)
    }
    
    func cleaningsCount() -> Int {
        return cleaningsArray.count
    }
    
    func fillCleaningsShortDetailsIn(Cell cell: CleaningsMapCollectionViewCell, byIndex index: Int){
        cell.district = cleaningsDistricts[index]
        cell.address = cleaningsArray[index].address
        if let coordinator = cleaningsCoordinators[index].first {
            cell.coordinator = "Координатор: \(coordinator.firstName) \(coordinator.lastName ?? "")"
        } else {
            cell.coordinator = ""
        }
        cell.participants = "Пойдет: \(cleaningsArray[index].cleanersIds?.count)"
        cell.distance = "\(String(describing: cleaningDistances[index] ?? 0)) КМ"
    }
    
    func getStreetImageURLViewForCellBy(Index index: Int) -> URL?{
        return streetViewImages[index]
    }
    
    func getCleaningBy(Index index: Int) -> Cleaning?{
        return cleaningsArray[index]
    }
    
    func getCoordinatorsBy(Index index: Int) -> [User]?{
        return cleaningsCoordinators[index]
    }

    private func loadDistanceToCleanings(){
        if cleaningsArray.count != 0{
            self.cleaningDistances.removeAll()
            self.cleaningDistances = [Double?](repeatElement(nil, count: self.cleaningsArray.count))
            for (index, cleaning) in cleaningsArray.enumerated(){
                let distance : Double?
                if CLLocationManager().location != nil{
                    let destination = CLLocation(latitude: cleaning.coordinate.latitude, longitude: cleaning.coordinate.longitude)
                    distance = CLLocationManager().location!.distance(from: destination) / 1000
                } else {
                    distance = nil
                }
                self.cleaningDistances[index] = distance?.rounded()
            }
        }
    }
    
    private func fillMemberDistrictArraysAndStreetViewUrl() {
        for (index, cleaning) in cleaningsArray.enumerated() {
            if cleaning.coordinatorsIds != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { users in
                    self.cleaningsCoordinators[index] = users
                })
            }
            localityManager.searchForSublocalityWith(coordinates: cleaning.coordinate, handler: { (localityName) in
                self.cleaningsDistricts[index] = localityName
            })
            let streetViewFormatter = StreetViewFormatter()
            let urlString = streetViewFormatter.setStreetViewImageWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)")
            let url = URL(string: urlString)
            if url != nil {
                self.streetViewImages[index] = url!
            } else {
                self.streetViewImages[index] = nil
            }
        }
    }
    
    func getCleaningsIdsAndCoordinates() -> [(String, CLLocationCoordinate2D)] {
        var array = [(String,CLLocationCoordinate2D)]()
        for cleaning in cleaningsArray{
            let tuple = (cleaning.ID, cleaning.coordinate)
            array.append(tuple)
        }
        return array
    }
    
    func addCleaningsObservers() {
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCleaningsWith),
                                               name: kCleaningsManagerCleaningModifyNotification,
                                               object: nil)
    }
    
    func removeCleaningsObservers() {
        NotificationCenter.default.removeObserver(self, name: kCleaningsManagerCleaningModifyNotification, object: nil)
    }
    
    @objc func updateCleaningsWith(notification:Notification) {
        loadCleanings()
        
    }
}

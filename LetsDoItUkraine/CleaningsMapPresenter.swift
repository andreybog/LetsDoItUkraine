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
    func didUpdateCurrentCleanings()
}

class CleaningsMapPresenter {
    
    var delegate : CleaningsMapPresentDelegate!
    private let localityManager = LocalityManager()
    
    private let cleaningsManager = CleaningsManager.defaultManager
    private let usersManager = UsersManager.defaultManager
    
    private var cleaningsArray = [Cleaning]()
    private var currentCleaningsArray = [Cleaning]()
    private var cleaningsCoordinators = [[User]?]()
    private var cleaningsDistricts = [String]()
    private var streetViewImages = [URL?]()
    private var cleaningDistances = [Double?]()
    
    init() {
        addCleaningsObservers()
    }
    
    deinit {
        removeCleaningsObservers()
    }
    
    func loadCleanings() {
        self.cleaningsArray = [Cleaning](self.cleaningsManager.activeCleanings.values)
        self.delegate?.didUpdateCleanings()
    }
    
    func prepareCollectionViewWith(Coordinates coordinate: CLLocationCoordinate2D){
        var distanceArray = [(Int, Double)]()
        let selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        for (index,cleaning) in cleaningsArray.enumerated(){
            let distance = selectedLocation.distance(from: CLLocation(latitude: cleaning.coordinate.latitude, longitude: cleaning.coordinate.longitude)) / 1000
            distanceArray.append((index, distance.rounded()))
        }
        distanceArray = distanceArray.sorted { $0.1 < $1.1 }
        self.currentCleaningsArray.removeAll()
        var cellsCount = 20
        if cellsCount > cleaningsArray.count{
            cellsCount = cleaningsArray.count
        }
        for i in 0..<cellsCount {
            self.currentCleaningsArray.insert(cleaningsArray[distanceArray[i].0], at: i)
        }
        self.loadDistanceToCleanings()
        self.fillMemberDistrictArraysAndStreetViewUrl()
    }
    
    func prepareCollectionViewAndGetCoordinatesWith(ID number: String) -> (CLLocationCoordinate2D){
        var selectedCleaning = Cleaning()
        for cleaning in cleaningsArray{
            if cleaning.ID == number{
                selectedCleaning = cleaning
            }
        }
        var distanceArray = [(Int, Double)]()
        let selectedLocation = CLLocation(latitude: selectedCleaning.coordinate.latitude, longitude: selectedCleaning.coordinate.longitude)
        for (index,cleaning) in cleaningsArray.enumerated(){
            if cleaning.ID == selectedCleaning.ID{
                continue
            }
            let distance = selectedLocation.distance(from: CLLocation(latitude: cleaning.coordinate.latitude, longitude: cleaning.coordinate.longitude)) / 1000
            distanceArray.append((index, distance.rounded()))
        }
        distanceArray = distanceArray.sorted { $0.1 < $1.1 }
        self.currentCleaningsArray.removeAll()
        currentCleaningsArray.insert(selectedCleaning, at: 0)
        var cellsCount = 20
        if cellsCount > cleaningsArray.count{
            cellsCount = cleaningsArray.count
        }
        for i in 1..<cellsCount {
            self.currentCleaningsArray.insert(cleaningsArray[distanceArray[i-1].0], at: i)
        }
        self.loadDistanceToCleanings()
        self.fillMemberDistrictArraysAndStreetViewUrl()
        return (selectedCleaning.coordinate)
    }
    
    func cleaningsCount() -> Int {
        return currentCleaningsArray.count
    }
    
    func fillCleaningsShortDetailsIn(Cell cell: CleaningsMapCollectionViewCell, byIndex index: Int){
        if !currentCleaningsArray.isEmpty{
            if !cleaningsDistricts.isEmpty{
                cell.district = cleaningsDistricts[index]
            } else {
                cell.district = "Район загружается..."
            }
            cell.address = currentCleaningsArray[index].address
            if !cleaningsCoordinators.isEmpty{
                if let coordinator = cleaningsCoordinators[index]?.first {
                cell.coordinator = "Координатор: \(coordinator.firstName) \(coordinator.lastName ?? "")"
                } else {
                    cell.coordinator = "Координатор: Загружается..."
                }
            } else {
                cell.coordinator = "Координатор: Загружается..."
            }
            cell.participants = "Пойдет: \(currentCleaningsArray[index].cleanersIds?.count ?? 0)"
            cell.distance = "\(String(describing: cleaningDistances[index] ?? 0)) КМ"
        }
    }
    
    func getStreetImageURLViewForCellBy(Index index: Int) -> URL?{
        return streetViewImages[index]
    }
    
    func getCleaningBy(Index index: Int) -> Cleaning?{
        return currentCleaningsArray[index]
    }
    
    func getCoordinatorsBy(Index index: Int) -> [User]?{
        return cleaningsCoordinators[index]
    }

    private func loadDistanceToCleanings() {
        if currentCleaningsArray.count != 0 {
            self.cleaningDistances.removeAll()
            self.cleaningDistances = [Double?](repeatElement(nil, count: self.currentCleaningsArray.count))
            for (index, cleaning) in currentCleaningsArray.enumerated(){
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
        self.cleaningsCoordinators = [[User]?](repeatElement(nil, count: currentCleaningsArray.count))
        for (index, cleaning) in currentCleaningsArray.enumerated() {
            
            if cleaning.coordinatorsIds != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { [unowned self] users in
                    self.cleaningsCoordinators.insert(users, at: index)
                    self.delegate?.didUpdateCurrentCleanings()
                })
            }
            
            self.cleaningsDistricts.insert("", at: index)
            localityManager.searchForSublocalityWith(coordinates: cleaning.coordinate, handler: { [unowned self] (localityName) in
                self.cleaningsDistricts.insert(localityName, at: index)
                self.delegate?.didUpdateCurrentCleanings()
            })
            
            let streetViewFormatter = StreetViewFormatter()
            let urlString = streetViewFormatter.setStreetViewImageWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)")
            let url = URL(string: urlString)
            self.streetViewImages.insert(url, at: index)
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

//
//  RecycePointMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

protocol RecyclePointsCollectionViewFillingProtocol {
    var title: String! { get set }
    var address: String! {get set}
    var distance : String! {get set}
    var workingHours : String! {get set}
    var type : String! {get set}
}

extension RecyclePointMapCollectionViewCell : RecyclePointsCollectionViewFillingProtocol{
    var address : String! {
        get{
            return self.recyclePointAddressLabel.text
        }
        set{
            self.recyclePointAddressLabel.text = newValue
        }
    }
    var title: String! {
        get{
            return self.recyclePointTitleLabel.text
        }
        set {
            self.recyclePointTitleLabel.text = newValue
        }
    }
    var distance: String! {
        get{
            return self.recyclePointDistanceLabel.text
        }
        set{
            self.recyclePointDistanceLabel.text = newValue
        }
    }
    var workingHours: String! {
        get{
            return self.RecyclePointWorkingHoursLabel.text
        }
        set{
            self.RecyclePointWorkingHoursLabel.text = newValue
        }
    }
    var type: String! {
        get{
            return self.recycleTypeLabel.text
        }
        set{
            self.recycleTypeLabel.text = newValue
        }
    }
}

protocol RecyclePointMapPresentDelegate{
    func didUpdateRecyclePoints()
}

class RecyclePointMapPresenter {
    
    var delegate : RecyclePointMapPresentDelegate!
    
    private let pointsManager = RecyclePointsManager.defaultManager
    private var pointsArray = [RecyclePoint]()
    private var currentPointsArray = [RecyclePoint]()
    private var pointsURL = [URL?]()
    private var recyclePointCategories = Set<RecyclePointCategory>()
    private var controlGroupCategories = Set<RecyclePointCategory>()
    private var pointCategories = [String]()
    private var pointDistances = [Double?]()
    private var hasFilterChanged = false

    init() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        self.controlGroupCategories = self.recyclePointCategories
        pointsManager.getAllRecyclePoints { (points) in
            self.pointsArray = points
        }
    }
    
    func pointsCount() -> Int{
        return currentPointsArray.count
    }
    
    func getPointBy(Index index: Int) -> RecyclePoint? {
        return currentPointsArray[index]
    }
    
    func fillRecyclePointShortDetailsIn(Cell cell: RecyclePointMapCollectionViewCell, byIndex index: Int){
        cell.address = currentPointsArray[index].address 
        cell.distance = "\(String(describing: pointDistances[index] ?? 0)) КМ"
        cell.title = currentPointsArray[index].title
        cell.type = pointCategories[index]
        cell.workingHours = currentPointsArray[index].schedule ?? ""
    }
    
    func getPointsIdsAndCoordinates() -> [(String, CLLocationCoordinate2D)] {
        var array = [(String,CLLocationCoordinate2D)]()
        for point in pointsArray{
            let tuple = (point.ID, point.coordinate)
            array.append(tuple)
        }
        return array
    }
    
    func prepareCollectionViewWith(Coordinates coordinate: CLLocationCoordinate2D){
        if pointsArray.count == 1 {
            self.currentPointsArray.removeAll()
            self.currentPointsArray.insert(pointsArray[0], at: 0)
        } else {
            var distanceArray = [(Int, Double)]()
            let selectedLocation = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            for (index,point) in pointsArray.enumerated(){
                let distance = selectedLocation.distance(from: CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)) / 1000
                distanceArray.append((index, distance.rounded()))
            }
            distanceArray = distanceArray.sorted { $0.1 < $1.1 }
            self.currentPointsArray.removeAll()
            for i in 0..<20 {
                self.currentPointsArray.insert(pointsArray[distanceArray[i].0], at: i)
            }
        }
        self.loadImageURLs()
        self.loadRecyclePointCategories()
        self.loadDistanceToPoints()
    }
    
    func prepareCollectionViewAndGetCoordinatesWith(ID number: String) -> (CLLocationCoordinate2D){
        var selectedPoint = RecyclePoint()
        for point in pointsArray{
            if point.ID == number{
                selectedPoint = point
            }
        }
        if pointsArray.count > 1{
            var distanceArray = [(Int, Double)]()
            let selectedLocation = CLLocation(latitude: selectedPoint.coordinate.latitude, longitude: selectedPoint.coordinate.longitude)
            for (index,point) in pointsArray.enumerated(){
                if point.ID == selectedPoint.ID{
                    continue
                }
                let distance = selectedLocation.distance(from: CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)) / 1000
                distanceArray.append((index, distance.rounded()))
            }
            distanceArray = distanceArray.sorted { $0.1 < $1.1 }
            self.currentPointsArray.removeAll()
            currentPointsArray.insert(selectedPoint, at: 0)
            var cellsCount = 20
            if cellsCount > currentPointsArray.count{
                cellsCount = currentPointsArray.count
            }
            for i in 1..<20 {
                self.currentPointsArray.insert(pointsArray[distanceArray[i-1].0], at: i)
            }
        } else {
            self.currentPointsArray.removeAll()
            self.currentPointsArray.insert(selectedPoint, at: 0)
        }
        self.loadImageURLs()
        self.loadRecyclePointCategories()
        self.loadDistanceToPoints()
        return (selectedPoint.coordinate)
    }
    
    
    func sortFunc(tup1: (Int, Double), tup2: (Int, Double)) -> Bool {
        return tup1.1 < tup2.1
    }
    
    func getStreetImageURLViewForCellBy(Index index: Int) -> URL?{
        return pointsURL[index]
    }
    
    private func loadAllPoints() {
        pointsManager.getAllRecyclePoints { (recyclePoints) in
            self.pointsArray = recyclePoints
            self.delegate?.didUpdateRecyclePoints()
        }
    }
    
    private func loadPointsWith(categories: Set<RecyclePointCategory>) {
        pointsManager.getSelectedRecyclePoints(categories: categories, handler:{ (points) in
            self.pointsArray = points
            self.delegate?.didUpdateRecyclePoints()
        })
    }
    
    private func loadDistanceToPoints() {
        if !currentPointsArray.isEmpty {
            pointDistances.removeAll()
            self.pointDistances = [Double?](repeatElement(nil, count: self.currentPointsArray.count))
            for (index, point) in currentPointsArray.enumerated() {
                let distance : Double?
                if CLLocationManager().location != nil {
                    let destination = CLLocation(latitude: point.coordinate.latitude, longitude: point.coordinate.longitude)
                    distance = CLLocationManager().location!.distance(from: destination) / 1000
                } else {
                    distance = nil
                }
                self.pointDistances[index] = distance?.rounded()
            }
        }
    }
    
    private func loadImageURLs() {
        if !currentPointsArray.isEmpty {
            pointsURL.removeAll()
            pointsURL = [URL?](repeatElement(nil, count: currentPointsArray.count))
            for (index,point) in currentPointsArray.enumerated(){
                let coordinate = "\(point.coordinate.latitude), \(point.coordinate.longitude)"
                let streetViewFormatter = StreetViewFormatter()
                let urlString = streetViewFormatter.setStreetViewImageWith(coordinates: coordinate)
                
                if let url = URL(string: urlString) {
                    self.pointsURL[index] = url
                }
            }
        }
    }
    
    private func loadRecyclePointCategories() {
        if !currentPointsArray.isEmpty {
            pointCategories.removeAll()
            self.pointCategories = [String](repeatElement("", count: self.currentPointsArray.count))
            for (index, point) in currentPointsArray.enumerated() {
                let categories = point.categories
                self.pointCategories[index] = categories.map { $0.literal }.joined(separator: ",")
            }
        }
    }
    
    func hasFiltersChanged() -> Bool{
        return self.hasFilterChanged
    }
    
    func loadPoints() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        if self.recyclePointCategories != self.controlGroupCategories {
            self.controlGroupCategories = self.recyclePointCategories
            self.hasFilterChanged = true
        } else {
            self.hasFilterChanged = false
        }
        if recyclePointCategories.count != 0{
            self.loadPointsWith(categories: self.recyclePointCategories)
        } else {
            self.loadAllPoints()
        }
    }
}

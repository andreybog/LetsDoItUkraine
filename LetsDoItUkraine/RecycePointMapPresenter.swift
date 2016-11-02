//
//  RecycePointMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

protocol CollectionViewFillingProtocol {
    var title: String! { get set }
    var address: String! {get set}
    var distance : String! {get set}
    var workingHours : String! {get set}
    var type : String! {get set}
}

extension RecyclePointMapCollectionViewCell : CollectionViewFillingProtocol{
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
    
    private let locationManager = LocationManager()
    var delegate : RecyclePointMapPresentDelegate!
    
    private let pointsManager = RecyclePointsManager.defaultManager
    //Under Construction
    var pointsArray = [RecyclePoint]()
    private var pointsURL = [URL?]()
    private var recyclePointCategories = Set<RecyclePointCategory>()
    private var pointCategories = [String]()
    private var pointDistances = [Double?]()

    init() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        pointsManager.getAllRecyclePoints { (points) in
            self.pointsArray = points
            self.pointsURL = [URL?](repeatElement(nil, count: self.pointsArray.count))
            self.pointCategories = [String](repeatElement("", count: self.pointsArray.count))
            self.pointDistances = [Double?](repeatElement(nil, count: self.pointsArray.count))
        }
    }
    
    func pointsCount() -> Int{
        return pointsArray.count
    }
    
    func getPointBy(Index index: Int) -> RecyclePoint? {
        return pointsArray[index]
    }
    
    func fillRecyclePointShortDetailsIn(Cell cell: RecyclePointMapCollectionViewCell, byIndex index: Int){
        cell.address = pointsArray[index].address
        cell.distance = "\(String(describing: pointDistances[index] ?? 0)) КМ"
        cell.title = pointsArray[index].title
        cell.type = pointCategories[index]
        cell.workingHours = pointsArray[index].schedule ?? ""
    }
    
    func getPointsIdsAndCoordinates() -> [(String, CLLocationCoordinate2D)] {
        var array = [(String,CLLocationCoordinate2D)]()
        for point in pointsArray{
            let tuple = (point.ID, point.coordinate)
            array.append(tuple)
        }
        return array
    }
    
    func getCoordinatesBy(ID number: String) -> (AnyObject?, Int?){
        for (index,point) in pointsArray.enumerated(){
            if point.ID == number{
                return (point.coordinate as AnyObject?, index)
            }
        }
        return (nil, nil)
    }
    
    func getStreetImageURLViewForCellBy(Index index: Int) -> URL?{
        return pointsURL[index]
    }
    
    private func loadAllPoints() {
        pointsManager.getAllRecyclePoints { (recyclePoints) in
            self.pointsArray = recyclePoints
            self.loadImageURLs()
            self.loadRecyclePointCategories()
            self.loadDistanceToPoints()
            if self.delegate != nil{
                self.delegate.didUpdateRecyclePoints()
            }
        }
    }
    
    private func loadPointsWith(categories: Set<RecyclePointCategory>) {
        pointsManager.getSelectedRecyclePoints(categories: categories, handler:{ (points) in
            self.pointsArray = points
            self.loadImageURLs()
            self.loadRecyclePointCategories()
            self.loadDistanceToPoints()
            if self.delegate != nil{
                self.delegate.didUpdateRecyclePoints()
            }
        })
    }
    
    private func loadDistanceToPoints(){
        if pointsArray.count != 0{
            pointDistances.removeAll()
            self.pointDistances = [Double?](repeatElement(nil, count: self.pointsArray.count))
            for (index, point) in pointsArray.enumerated(){
                let distance = locationManager.getDistanceFromLocationWith(coordinate: point.coordinate)
                self.pointDistances[index] = distance?.rounded()
            }
        }
    }
    
    private func loadImageURLs() {
        if pointsArray.count != 0{
            pointsURL.removeAll()
            pointsURL = [URL?](repeatElement(nil, count: pointsArray.count))
            for (index,point) in pointsArray.enumerated(){
                let coordinate = "\(point.coordinate.latitude), \(point.coordinate.longitude)"
                let streetViewFormatter = StreetViewFormatter()
                let urlString = streetViewFormatter.setStreetViewImageWith(coordinates: coordinate)
                let url = URL(string: urlString)
                if url != nil{
                    self.pointsURL[index] = url
                }
            }
        }
    }
    
    private func loadRecyclePointCategories() {
        if pointsArray.count != 0{
            pointCategories.removeAll()
            self.pointCategories = [String](repeatElement("", count: self.pointsArray.count))
            for (index, point) in pointsArray.enumerated(){
                let categories = point.categories
                self.pointCategories[index] = categories.map { $0.literal }.joined(separator: ",")
            }
        }
    }
    
    func loadPoints() {
        self.recyclePointCategories = FiltersModel.sharedModel.categories
        if recyclePointCategories.count != 0{
            self.loadPointsWith(categories: self.recyclePointCategories)
        } else {
            self.loadAllPoints()
        }
    }
    
    func determineAutorizationStatus(handler: @escaping (_: String) -> Void) {
        self.locationManager.determineAutorizationStatus { (status) in
            handler(status)
        }
    }
    
    deinit {
        
    }
}

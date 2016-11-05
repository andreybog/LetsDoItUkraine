//
//  RecyclePointsManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation
import Firebase

extension RecycleCategory : FirebaseInitable {
    init?(data: [String : Any]) {
        
        guard let id = data["id"] as? String, let title = data["title"] as? String else {
            return nil
        }
        
        ID = id
        self.title = title
        
        if let urlString = data["picture"] as? String {
            picture = URL(string:urlString)
        } else {
            picture = nil
        }
    }
    
    var toJSON : [String : Any] {
        var data = ["id"    : ID,
                    "title" : title]
        
        if let picture = picture { data["picture"] = picture.absoluteString }
        
        return [ID : data]
    }
    
    var ref:FIRDatabaseReference {
        return RecyclePointsManager.defaultManager.dataManager.rootRef.child("\(RecycleCategory.rootDatabasePath)/\(ID)")
    }
    
    static var rootDatabasePath = "recycleCategories"
}

extension RecyclePoint : FirebaseInitable {
    init?(data: [String : Any]) {
        
        guard let id = data["id"] as? String, let title = data["title"] as? String,
            let addr = data["address"] as? String else {
                return nil
        }
        
        ID = id
        self.title = title
        phone = data["phone"] as? String
        website = data["website"] as? String
        address = addr
        schedule = data["schedule"] as? String
        summary = data["summary"] as? String
        
        coordinate = CLLocationCoordinate2D(latitude: data["latitude"] as! Double ,
                                            longitude: data["longitude"] as! Double)
        
        if let logoString = data["logo"] as? String {
            logo = URL(string: logoString)
        } else {
            logo = nil
        }
        if let pictureString = data["picture"] as? String {
            picture = URL(string: pictureString)
        } else {
            picture = nil
        }
        
        categories = Set<RecyclePointCategory>((data["categories"] as! [String]).map {
            return RecyclePointCategory(rawValue: $0)!
        })
    }
    
    var toJSON : [String : Any] {
        var data: [String : Any] = ["id"        : ID,
                                    "title"     : title,
                                    "latitude"  : coordinate.latitude,
                                    "longitude" : coordinate.longitude,
                                    "categories" : categories,
                                    "address"   : address]
        
        if let phone = phone { data["phone"] = phone }
        if let website = website { data["website"] = website }
        if let schedule = schedule { data["schedule"] = schedule }
        if let summary = summary { data["summary"] = summary }
        if let logo = logo { data["logo"] = logo.absoluteString }
        if let picture = picture { data["picture"] = picture.absoluteString }
        
        return [ID : title]
    }
    
    var ref:FIRDatabaseReference {
        return RecyclePointsManager.defaultManager.dataManager.rootRef.child("\(RecyclePoint.rootDatabasePath)/\(ID)")
    }
   
    static var rootDatabasePath = "recyclePoints"
}

class RecyclePointsManager {
    
    static let defaultManager = RecyclePointsManager()
    fileprivate var dataManager = DataManager.sharedManager
    
    
    // MARK: - GET METHODS
    
    func getRecylcePoint(withId pointId:String, handler: @escaping (_:RecyclePoint?) -> Void) {
        let refPoint = dataManager.rootRef.child("\(RecyclePoint.rootDatabasePath)/\(pointId)")
        dataManager.getObject(fromReference: refPoint, handler: handler)
    }
    
    func getAllRecyclePoints(with handler: @escaping (_:[RecyclePoint]) -> Void) {
        let refPoints = dataManager.rootRef.child(RecyclePoint.rootDatabasePath)
        dataManager.getObjects(fromReference: refPoints, handler: handler)
    }
    
    func getRecylceCategory(withId categoryId:String, handler: @escaping (_:RecycleCategory?) -> Void) {
        let refCategory = dataManager.rootRef.child("\(RecycleCategory.rootDatabasePath)/\(categoryId)")
        dataManager.getObject(fromReference: refCategory, handler: handler)
    }
    
    func getAllRecycleCategories(with handler: @escaping (_:[RecycleCategory]) -> Void) {
        let refCategories = dataManager.rootRef.child(RecycleCategory.rootDatabasePath)
        dataManager.getObjects(fromReference: refCategories, handler: handler)
    }
    
    func getSelectedRecyclePoints(categories: Set<RecyclePointCategory>, handler: @escaping (_: [RecyclePoint]) -> Void) {
        getAllRecyclePoints { (points) in
            let filteredPoints = points.filter({point in !categories.intersection(point.categories).isEmpty })
            handler(filteredPoints)
        }
    }
    
    // MARK: - MODIFY METHODS
    
    func createRecylePoint(_ recyclePoint: RecyclePoint) {
        let recyclePointsRootRef = dataManager.rootRef.child(RecyclePoint.rootDatabasePath)
        let recyclePointId = recyclePointsRootRef.childByAutoId().key
        var recyclePoint = recyclePoint
        
        recyclePoint.ID = recyclePointId
        dataManager.createObject(recyclePoint)
    }
}














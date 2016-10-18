//
//  RecyclePointsManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

extension RecycleCategory : FirebaseInitable {
  init?(data: [String : Any ]) {
    guard let key = data.keys.first, let data = data[key] as? [String : Any] else { return nil }
    
    ID = key
    title = data["title"] as! String
    
    if let urlString = data["picture"] as? String {
      picture = URL(string:urlString)
    } else {
      picture = nil
    }
  }
  
  var dictionary : [String : Any] {
    var data = ["title" : title]
    
    if let picture = picture { data["picture"] = picture.absoluteString }
    
    return [ID : data]
  }
  
  static var rootDatabasePath = "recycleCategories"
}

extension RecyclePoint : FirebaseInitable {
  init?(data: [String : Any ]) {
    guard let key = data.keys.first, let data = data[key] as? [String:Any] else { return nil }
    
    ID = key
    title = data["title"] as! String
    phone = data["phone"] as? String
    website = data["website"] as? String
    address = data["address"] as! String
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
    
    if let categories = data["categories"] as? [String] {
      self.categories = categories
    } else {
      self.categories = []
    }
  }
  
  var dictionary : [String : Any] {
    var data: [String : Any] = ["title"     : title,
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
  
  static var rootDatabasePath = "recyclePoints"
}

class RecyclePointsManager {
  
  static let defaultManager = RecyclePointsManager()
  private var dataManager = DataManager.sharedManager
  
  // MARK: - GET METHODS
  
  func getRecylcePoint(withId pointId:String, handler: @escaping (_:RecyclePoint?) -> Void) {
    let refPoint = dataManager.ref.child("recyclePoints/\(pointId)")
    dataManager.getObject(fromReference: refPoint, handler: handler)
  }
  
  func getAllRecyclePoints(with handler: @escaping (_:[RecyclePoint]) -> Void) {
    let refPoints = dataManager.ref.child("recyclePoints")
    dataManager.getObjects(fromReference: refPoints, handler: handler)
  }
  
  func getRecylceCategory(withId categoryId:String, handler: @escaping (_:RecycleCategory?) -> Void) {
    let refCategory = dataManager.ref.child("recycleCategories/\(categoryId)")
    dataManager.getObject(fromReference: refCategory, handler: handler)
  }
  
  func getAllRecycleCategories(with handler: @escaping (_:[RecycleCategory]) -> Void) {
    let refCategories = dataManager.ref.child("recycleCategories")
    dataManager.getObjects(fromReference: refCategories, handler: handler)
  }
  
  // MARK: - MODIFY METHODS
  
  func createRecylePoint(_ recyclePoint: RecyclePoint) {
    let recyclePointsRootRef = dataManager.ref.child(RecyclePoint.rootDatabasePath)
    let recyclePointId = recyclePointsRootRef.childByAutoId().key
    var recyclePoint = recyclePoint
    
    recyclePoint.ID = recyclePointId
    dataManager.createObject(recyclePoint)
  }
}

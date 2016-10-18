//
//  CleaningsManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase
import CoreLocation

extension Cleaning : FirebaseInitable {
  
  init?(data: [String : Any]) {
    guard let key = data.keys.first, let data = data[key] as? [String : Any] else { return nil }
    
    ID = key
    address = data["address"] as! String
    
    if let dateString = data["datetime"] as? String {
      datetime = dateString.date()
    } else {
      datetime = nil
    }
    summary = data["description"] as? String
    isActive = data["active"] as! Bool
    cooridnate = CLLocationCoordinate2D(latitude: data["latitude"] as! Double,
                                        longitude: data["longitude"] as! Double)
    
    if let picturesDict = data["pictures"] as? [String : String] {
      var pictures = [URL]()
      for (_, val) in picturesDict {
        pictures.append(URL(string:val)!)
      }
      self.pictures = pictures
    } else {
      self.pictures = nil
    }
    
  }
  
  var dictionary: [String : Any] {
    var data: [String : Any] = ["active"    : isActive,
                                "latitude"  : cooridnate.latitude,
                                "longitude" : cooridnate.longitude,
                                "address"   : address]
    
    if let datetime = datetime { data["dateTime"] = datetime.string() }
    if let summary = summary { data["description"] = summary }
    if let pictures = pictures {
      var picDict = [String:String]()
      for (index, url) in pictures.enumerated() {
        picDict[String(index)] = url.absoluteString
      }
      data["pictures"] = picDict
    }
    return [ID : data]
  }
  
  static var rootDatabasePath: String = "cleanings"
}

enum CleaningFiler {
  case all, active, past
}

enum ClenaingMembersFilter {
  case coordinator, cleaner
}

class CleaningsManager {
  
  static let defaultManager = CleaningsManager()
  private var dataManager = DataManager.sharedManager
  
  // MARK: - GET METHODS
  
  func getCleaning(withId cleaningId:String, handler: @escaping (_: Cleaning?)->Void) {
    let reference = dataManager.ref.child("\(Cleaning.rootDatabasePath)/\(cleaningId)")
    dataManager.getObject(fromReference: reference,handler: handler)
  }

  func getCleanings(filer: CleaningFiler, with handler: @escaping (_:[Cleaning]) -> Void) {
    var refCleanings: FIRDatabaseQuery = dataManager.ref.child(Cleaning.rootDatabasePath)
    
    switch filer {
    case .active:
      refCleanings = refCleanings.queryOrdered(byChild: "active").queryEqual(toValue: true)
    case .past:
      refCleanings = refCleanings.queryOrdered(byChild: "active").queryEqual(toValue: false)
    default:
      break
    }
    
    dataManager.getObjects(fromReference: refCleanings, handler: handler)
  }
  
  func getCleaningMembers(cleaningId: String, filter: ClenaingMembersFilter, handler: @escaping (_:[User]) -> Void) {
    let refPath = cleaningMembersReferencePath(cleaningId: cleaningId, filter: filter)
    let reference = dataManager.ref.child(refPath)
    
    dataManager.getObjects(fromReference: reference, handler: handler)
  }
  
  func getCleaningMembersCount(cleaningId: String, filter: ClenaingMembersFilter, handler: @escaping (_:UInt) -> Void) {
    let refPath = cleaningMembersReferencePath(cleaningId: cleaningId, filter: filter)
    let reference = dataManager.ref.child(refPath)
    
    dataManager.getObjectsCount(fromReference: reference, handler: handler)
  }
  
  private func cleaningMembersReferencePath(cleaningId: String, filter: ClenaingMembersFilter) -> String {
    switch filter {
    case .coordinator:    return "cleaning-members/\(cleaningId)/coordinators"
    case .cleaner:        return "cleaning-members/\(cleaningId)/cleaners"
    }
  }
  
  
  // MARK: - MODIFY METHODS
  
  func createCleaning(_ cleaning:Cleaning, byCoordinator user:User) {
    let cleaningsRootRef = dataManager.ref.child(Cleaning.rootDatabasePath)
    let cleaningId = cleaningsRootRef.childByAutoId().key
    var cleaning = cleaning
    
    cleaning.ID = cleaningId
    dataManager.createObject(cleaning)
    addMember(user, toCleaning: cleaning, as: .coordinator)
  }
  
  func addMember(_ user:User, toCleaning cleaning: Cleaning, as memberType: ClenaingMembersFilter) {
    updateMember(user, withCleaning: cleaning, as: memberType, add: true)
  }
  
  func removeMember(_ user:User, fromCleaning cleaning: Cleaning, as memberType: ClenaingMembersFilter) {
    updateMember(user, withCleaning: cleaning, as: memberType, add: false)
  }
  
  private func updateMember(_ user:User, withCleaning cleaning: Cleaning, as memberType: ClenaingMembersFilter, add: Bool) {
    var userPath: String
    var cleaningPath: String
    
    switch memberType {
    case .coordinator:
      userPath = "asCoordinator"
      cleaningPath = "coordinators"
    case .cleaner:
      userPath = "asCleaner"
      cleaningPath = "cleaners"
    }
    
    let userUpdatePath = "user-cleanings/\(user.ID)/\(userPath)/\(cleaning.ID)"
    let cleaningUpdatePath = "cleaning-members/\(cleaning.ID)/\(cleaningPath)/\(user.ID)"
    
    let value:Any = add ? true : NSNull()
    let valuesForUpdate = [userUpdatePath : value,
                           cleaningUpdatePath : value]
    
    dataManager.updateObjects(valuesForUpdate)
  }
}

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
    address = data["address"] as? String
    
    if let dateString = data["datetime"] as? String {
      datetime = dateString.date()
      print("datetime: \(datetime)")
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
    return [:]
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
    var refPath = "cleaning-members/\(cleaningId)"
    
    switch filter {
    case .coordinator:    refPath.append("/coordinators")
    case .cleaner:        refPath.append("/cleaners")
    }
    let reference = dataManager.ref.child(refPath)
    
    dataManager.getObjects(fromReference: reference, handler: handler)
  }

}

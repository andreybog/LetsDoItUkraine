//
//  UsersManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

extension User : FirebaseInitable {
  
  init?(data: [String : Any]) {
    guard let key = data.keys.first, let data = data[key] as? [String : Any] else { return nil }
    
    ID = key
    firstName = data["firstName"] as! String
    lastName = data["lastName"] as? String
    phone = data["phone"] as? String
    country = data["country"] as? String
    city = data["city"] as? String
    email = data["email"] as? String
    
    if let picUrl = data["picture"] as? String {
      photo = URL(string:picUrl)
    } else {
      photo = nil
    }
  }
  
  var dictionary: [String : Any] {
    var data = ["firstName" : firstName]
    
    if let lastName   = lastName { data["lastName"] = lastName }
    if let phone      = phone { data["phone"] = phone }
    if let country    = country { data["country"] = country }
    if let city       = city { data["city"] = city }
    if let email      = email { data["email"] = email }
    if let photo      = photo { data["picture"] = photo.absoluteString }
    
    return [ID : data]
  }
  
  static var rootDatabasePath: String = "users"
}

enum UserClenaingsFilter {
  case asModerator, asCleaner, past
}

class UsersManager {
  
  static let defaultManager = UsersManager()
  private var dataManager = DataManager.sharedManager
  
  func getUser(withId userId:String, handler: @escaping (_: User?)->Void) {
    let reference =  dataManager.ref.child("\(User.rootDatabasePath)/\(userId)")
    dataManager.getObject(fromReference: reference, handler: handler)
  }
  
  func getUserCleanings(userId: String, filter: UserClenaingsFilter, handler: @escaping (_:[Cleaning]) -> Void) {
    var refPath = "user-cleanings/\(userId)"
    
    switch filter {
    case .asModerator:  refPath.append("/asModerator")
    case .asCleaner:    refPath.append("/asCleaner")
    case .past:         refPath.append("/past")
    }
    
    let reference =  dataManager.ref.child(refPath)
    dataManager.getObjects(fromReference: reference, handler: handler)
  }
  
  func addUser(_ user: User) {
    if user.ID.isEmpty || user.ID.rangeOfCharacter(from: kForbiddenPathCharacterSet) != nil {
      print("Error: userID Must be a non-empty string and not contain '.' '#' '$' '[' or ']''")
      return
    }
      
    let reference =  dataManager.ref.child(User.rootDatabasePath)
    
    reference.child(user.ID).observeSingleEvent(of: .value, with: { [unowned self] (snapshot) in
      if !snapshot.exists() {
        self.dataManager.updateObject(user)
      } else {
        print("Error: User with id: '\(user.ID)' is already exist.")
      }
    })
  }
  
  
}

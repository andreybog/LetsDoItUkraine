//
//  UsersManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase

extension User : FirebaseInitable {
  
  init?(data: [String : Any]) {
    guard let id = data["id"] as? String, let fName = data["firstName"] as? String else { return nil }
    
    ID = id
    firstName = fName
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
    if let asCleaner = data["asCleaner"] as? [String:Bool] {
        asCleanerIds = [String](asCleaner.keys)
    } else { asCleanerIds = nil }
    
    if let asCoordinator = data["asCoordinator"] as? [String:Bool] {
        asCoordinatorIds = [String](asCoordinator.keys)
    } else { asCoordinatorIds = nil }
    
    if let pastCleanings = data["pastCleanings"] as? [String:Bool] {
        pastCleaningsIds = [String](pastCleanings.keys)
    } else { pastCleaningsIds = nil }
  }
  
  var dictionary: [String : Any] {
    var data: [String : Any] = ["id"        : ID,
                                "firstName" : firstName]
    
    if let lastName   = lastName { data["lastName"] = lastName }
    if let phone      = phone { data["phone"] = phone }
    if let country    = country { data["country"] = country }
    if let city       = city { data["city"] = city }
    if let email      = email { data["email"] = email }
    if let photo      = photo { data["picture"] = photo.absoluteString }
    
    if let asCleanerId = asCleanerIds {
        var asCleanerDict = [String:Bool]()
        for id in asCleanerId {
            asCleanerDict[id] = true
        }
        data["asCleaner"] = asCleanerDict
    }
    
    if let asCoordinatorId = asCoordinatorIds {
        var asCoordinatorDict = [String:Bool]()
        for id in asCoordinatorId {
            asCoordinatorDict[id] = true
        }
        data["asCoordinator"] = asCoordinatorDict
    }
    
    if let pastCleaningsId = pastCleaningsIds {
        var pastCleaningsDict = [String:Bool]()
        for id in pastCleaningsId {
            pastCleaningsDict[id] = true
        }
        data["pastCleanings"] = pastCleaningsDict
    }
    
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
  
    private var allUsers = [String:User]()
  
  //MARK: - GET USERS
  
  func getUser(withId userId:String, handler: @escaping (_: User?) -> Void) {
    if let user = allUsers[userId] {
        handler(user)
        return
    }
    
    let reference =  dataManager.rootRef.child("\(User.rootDatabasePath)/\(userId)")
    dataManager.getObject(fromReference: reference, handler: { [unowned self] (user) in
        if user != nil {
           self.allUsers[user!.ID] = user!
        }
        handler(user)
    } as (_:User?) -> Void)
  }
  
  func getAllUsers(handler: @escaping (_: [User]) -> Void) {
    let reference =  dataManager.rootRef.child(User.rootDatabasePath)
    dataManager.getObjects(fromReference: reference, handler: handler)
  }

    func getUsers(withIds ids: [String], handler: @escaping (_:[User]) -> Void) {
        var users = [User]()
        
        var usersCount = ids.count
        var currentUsersCount = 0
        for id in ids {
            getUser(withId: id, handler: { (user) in
                if user != nil {
                    users.append(user!)
                    currentUsersCount += 1
                } else {
                    usersCount -= 1
                }
                if currentUsersCount == usersCount {
                    handler(users)
                }
            })
        }
    }

      
  // MARK: - MODIFY USER
  
    func createUser(_ user: User) {
        self.dataManager.createObject(user)
    }
  
  
}

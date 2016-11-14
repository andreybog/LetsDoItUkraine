//
//  UsersManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase
import FBSDKLoginKit

extension User : FirebaseInitable {
    
    init?(data: [String:Any]) {
    
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
        
//        if let metadata = data["cleaningsMetadata"] as? [String : [String:Any]] {
//            cleaningsMetadata = metadata.map { (_, value) -> CleaningMetadata in
//                return CleaningMetadata(data: value)!
//            }
//        }
    }
    
    var toJSON: [String : Any] {
        var data: [String : Any] = ["id"        : ID,
                                    "firstName" : firstName]
        
        if let lastName   = lastName { data["lastName"] = lastName }
        if let phone      = phone { data["phone"] = phone }
        if let country    = country { data["country"] = country }
        if let city       = city { data["city"] = city }
        if let email      = email { data["email"] = email }
        if let photo      = photo { data["picture"] = photo.absoluteString }
        
        
        var metadata = [String : Any]()
        for data in cleaningsMetadata {
            metadata[data.ID] = data.toJSON
        }
        data["cleaningsMetadata"] = metadata
        
        
        return [ID : data]
    }
    
    var ref:FIRDatabaseReference {
        return UsersManager.defaultManager.dataManager.rootRef.child("\(User.rootDatabasePath)/\(ID)")
    }
    
    static var rootDatabasePath: String = "users"
}


// Cleanings Metadata extension - asCoordinator, asCleaner, pastCleanings
//
extension User {
    var asCoordinatorIds:[String]? {
        guard let pivotDate = UsersManager.defaultManager.dataManager.pivotDate else {
            return nil
        }
        
        return (cleaningsMetadata.filter { $0.startAt >= pivotDate && $0.userRole! == UserRole.coordinator }).map { $0.ID }
    }
    
    var asCleanerIds:[String]? {
        guard let pivotDate = UsersManager.defaultManager.dataManager.pivotDate else {
            return nil
        }
        
        return (cleaningsMetadata.filter { $0.startAt >= pivotDate && $0.userRole! == UserRole.cleaner }).map { $0.ID }
    }
    
    var pastCleaningsIds:[String]? {
        guard let pivotDate = UsersManager.defaultManager.dataManager.pivotDate else {
            return nil
        }
        
        return (cleaningsMetadata.filter { $0.startAt < pivotDate }).map { $0.ID }
    }
    
    func create(_ cleaning: Cleaning, withCompletionBlock block: @escaping (Error?, Cleaning?)->Void) {
        CleaningsManager.defaultManager.createCleaning(cleaning, byCoordinator: self, withCompletionBlock: block)
    }
    
    func go(to cleaning: Cleaning) {
        CleaningsManager.defaultManager.addMember(self, toCleaning: cleaning, as: .cleaner)
    }
    
    func refuse(from cleaning: Cleaning) {
        CleaningsManager.defaultManager.removeMember(self, fromCleaning: cleaning, as: .cleaner)
    }
}


class UsersManager {
  
  static let defaultManager = UsersManager()
  fileprivate var dataManager = DataManager.sharedManager
  
    private var allUsers = [String:User]()
    
    var currentUser:User? {
        willSet {
            if newValue == nil {
                currentUserCleanings = nil
                removeObservers()
            }
        }
        didSet {
            NotificationCenter.default.post(Notification(name: NotificationsNames.currentUserProfileChanged.name))
            if currentUser != nil, currentUser?.ID != oldValue?.ID {
                currentUserCleanings = [Cleaning]()
                addObservers()
            }
        }
    }
    
    var currentUserCleanings: [Cleaning]?
    
    var currentUserAsCoordinator: [Cleaning]? {
        guard let cleanings = currentUserCleanings, let pivotDate = dataManager.pivotDate else {
            return nil
        }
        return cleanings.filter { $0.startAt >= pivotDate && ($0.coordinatorsIds?.contains(currentUser!.ID) ?? false) }
    }
    
    var currentUserAsCleaner: [Cleaning]? {
        guard let cleanings = currentUserCleanings, let pivotDate = dataManager.pivotDate else {
            return nil
        }
        return cleanings.filter { $0.startAt >= pivotDate && ($0.cleanersIds?.contains(currentUser!.ID) ?? false) }
    }
    
    var currentUserPastCleanings: [Cleaning]? {
        guard let cleanings = currentUserCleanings, let pivotDate = dataManager.pivotDate else {
            return nil
        }
        return cleanings.filter { $0.startAt < pivotDate }
    }
    
    var isCurrentUserCanAddCleaning: Bool {
        return currentUser?.asCoordinatorIds?.isEmpty ?? true && currentUser?.asCleanerIds?.isEmpty ?? true
    }
    
    private var addHandler: FIRDatabaseHandle?
    private var changeHandler: FIRDatabaseHandle?
    private var removeHandler: FIRDatabaseHandle?
  
  //MARK: - GET USERS
    
    func getCurrentUser(handler: @escaping (_:User?)->Void) {
        
        guard let currentUser = FIRAuth.auth()?.currentUser else {
            return handler(nil)
        }
        
        getUser(withId: currentUser.uid, handler: { [unowned self] (user) in
            self.currentUser = user

            handler(user)
        })
    }
  
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
        
        guard !ids.isEmpty else {
            return handler(users)
        }
        
        let usersCount = ids.count
        var currentUsersCount = 0
        for id in ids {
            getUser(withId: id, handler: { (user) in
                if user != nil {
                    users.append(user!)
                }
                currentUsersCount += 1
                if currentUsersCount == usersCount {
                    handler(users)
                }
            })
        }
    }

      
  // MARK: - MODIFY USER
  
    func createUser(_ user: User, withCompletionBlock block: @escaping (_: Error?, _: User?) -> Void) {
        self.dataManager.createObject(user, withCompletionBlock: { (error, ref) in
            if error != nil {
                block(error, nil)
            } else {
                UsersManager.defaultManager.getUser(withId: user.ID, handler: { (user) in
                    if user != nil {
                        return block(nil, user)
                    }
                    let error = NSError(domain: "FIRDatabase: User not created", code: 111, userInfo: nil)
                    block(error, nil)
                })
            }
        })
    }
  
    func logOut() {
        currentUser = nil
        try? FIRAuth.auth()?.signOut()
        FBSDKLoginManager().logOut()
    }
    
  // MARK: - OBSERVERS
    
    private func addObservers() {
        addHandler = currentUser?.ref.child("cleaningsMetadata").observe(.childAdded, with: { [weak self] (snapshot) in
            
            if let data = snapshot.value as? [String : Any], let metadata = CleaningMetadata(data: data) {
                
                CleaningsManager.defaultManager.getCleaning(withId: metadata.ID, handler: { (cleaning) in
                    if cleaning != nil {
                        self?.currentUser?.cleaningsMetadata.append(metadata)
                        self?.currentUserCleanings?.append(cleaning!)
                        NotificationCenter.default.post(Notification(name: NotificationsNames.currentUserProfileChanged.name))
                    }
                })
            }
        })
        
        changeHandler = currentUser?.ref.child("cleaningsMetadata").observe(.childChanged, with: { [weak self] (snapshot) in
            if let data = snapshot.value as? [String : Any], let metadata = CleaningMetadata(data: data) {
                
                if let index = self?.currentUser?.cleaningsMetadata.index(where: { $0.ID == metadata.ID }) {
                    
                    CleaningsManager.defaultManager.getCleaning(withId: metadata.ID, handler: { (cleaning) in
                        if cleaning != nil {
                            self?.currentUser?.cleaningsMetadata[index] = metadata
                            self?.currentUserCleanings?[index] = cleaning!
                            NotificationCenter.default.post(Notification(name: NotificationsNames.currentUserProfileChanged.name))
                        }
                    })
                    
                }
            }
        })
        
        removeHandler = currentUser?.ref.child("cleaningsMetadata").observe(.childRemoved, with: { [weak self] (snapshot) in
            if let data = snapshot.value as? [String : Any], let metadata = CleaningMetadata(data: data) {
                
                if let index = self?.currentUser?.cleaningsMetadata.index(where: { $0.ID == metadata.ID }) {
                    self?.currentUser?.cleaningsMetadata.remove(at: index)
                    self?.currentUserCleanings?.remove(at: index)
                    NotificationCenter.default.post(Notification(name: NotificationsNames.currentUserProfileChanged.name))
                }
            }
            
        })
    }
    
    private func removeObservers() {
        if addHandler != nil { currentUser!.ref.child("cleaningsMetadata").removeObserver(withHandle: addHandler!) }
        if changeHandler != nil { currentUser!.ref.child("cleaningsMetadata").removeObserver(withHandle: changeHandler!) }
        if removeHandler != nil { currentUser!.ref.child("cleaningsMetadata").removeObserver(withHandle: removeHandler!) }
    }
    
}

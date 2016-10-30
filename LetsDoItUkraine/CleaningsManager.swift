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

extension CleaningMetadata : FirebaseInitable {
    init?(data:[String : Any]) {
        guard let id = data["id"] as? String,
                let userRole = data["userRole"] as? Int,
                let timeInterval = data["startAt"] as? TimeInterval else {
            return nil
        }
        
        ID = id
        self.userRole = UserRole(rawValue: userRole)
        startAt = Date(timeIntervalSince1970: timeInterval)
    }
    
    var toJSON: [String : Any] {
        return ["id" : ID,
                "userRole" : userRole,
                "startAt" : startAt.timeIntervalSince1970]
    }
    
    var ref:FIRDatabaseReference {
        return CleaningsManager.defaultManager.dataManager.rootRef
    }
    
    static var rootDatabasePath: String = ""
}

extension Cleaning : FirebaseInitable {
    
    init?(data: [String : Any]) {
        guard let id = data["id"] as? String, let addr = data["address"] as? String else {
            return nil
        }
        
        ID = id
        address = addr
        
        datetime = (data["dateTime"] as? String)?.date()
        createdAt = Date(timeIntervalSince1970: (data["createdAt"] as! Double))
        startAt = Date(timeIntervalSince1970: (data["startAt"] as! Double))
        summary = data["description"] as? String
        isActive = data["active"] as! Bool
        coordinate = CLLocationCoordinate2D(latitude: data["latitude"] as! Double,
                                            longitude: data["longitude"] as! Double)
        
        if let picturesDict = data["pictures"] as? [String : String] {
            self.pictures = picturesDict.map { (_, urlString) -> URL in
                return URL(string: urlString)!
            }
        } else {
            self.pictures = nil
        }
        
        if let coordinators = data["coordinators"] as? [String:Bool] {
            coordinatorsIds = [String](coordinators.keys)
        } else { coordinatorsIds = nil }
        
        if let cleaners = data["cleaners"] as? [String:Bool] {
            cleanersIds = [String](cleaners.keys)
        } else { cleanersIds = nil }
    }
    
    var toJSON: [String : Any] {
        var data: [String : Any] = ["id"        : ID,
                                    "active"    : isActive,
                                    "latitude"  : coordinate.latitude,
                                    "longitude" : coordinate.longitude,
                                    "address"   : address,
                                    "createdAt" : createdAt.timeIntervalSince1970,
                                    "startAt"   : startAt.timeIntervalSince1970]
        
        if let datetime = datetime { data["dateTime"] = datetime.string() }
        if let summary = summary { data["description"] = summary }
        
        
        if let pictures = pictures {
            var picDict = [String:String]()
            for (index, url) in pictures.enumerated() {
                picDict[String(index)] = url.absoluteString
            }
            data["pictures"] = picDict
        }
        
        if let coordinatorsIds = coordinatorsIds {
            var coordDict = [String:Bool]()
            for id in coordinatorsIds {
                coordDict[id] = true
            }
            data["coordinators"] = coordDict
        }
        
        if let cleanersId = cleanersIds {
            var cleanersDict = [String:Bool]()
            for id in cleanersId {
                cleanersDict[id] = true
            }
            data["cleaners"] = cleanersDict
        }
        
        return [ID : data]
    }
    
    var ref:FIRDatabaseReference {
        return CleaningsManager.defaultManager.dataManager.rootRef.child("\(Cleaning.rootDatabasePath)/\(ID)")
    }
    
    static var rootDatabasePath: String = "cleanings"
}

enum CleaningFilter {
    case all, active, past
}

let kCleaningsManagerCleaningAddNotification = NSNotification.Name("kCleaningsManagerCleaningAddNotification")
let kCleaningsManagerCleaningChangeNotification = NSNotification.Name("kCleaningsManagerCleaningChangeNotification")
let kCleaningsManagerCleaningRemoveNotification = NSNotification.Name("kCleaningsManagerCleaningRemoveNotification")
let kCleaningsManagerCleaningModifyNotification = NSNotification.Name("kCleaningsManagerCleaningModifyNotification")

let kCleaningsManagerCleaningKey = "kCleaningsManagerCleaningKey"

class CleaningsManager {

    static private(set) var defaultManager: CleaningsManager = {
        let manager = CleaningsManager()
        print("Cleanings manager: \(manager)")
        return manager
    }()
    
    var pivotDate:Date? {
        return dataManager.pivotDate
    }
    
    fileprivate var dataManager = DataManager.sharedManager
    
    var activeCleanings = [String:Cleaning]()
    private var pastCleanings = [String:Cleaning]()
    
    private var activeCleaningsRef: FIRDatabaseQuery? {

        if pivotDate == nil {
            return nil
        }
        return dataManager.rootRef.child(Cleaning.rootDatabasePath).queryOrdered(byChild: "startAt").queryStarting(atValue: pivotDate!.timeIntervalSince1970)
    }
    
    private var addHandler: FIRDatabaseHandle?
    private var changeHandler: FIRDatabaseHandle?
    private var removeHandler: FIRDatabaseHandle?
   
    private var timer:Timer?
    
    private init() {
        addObservers()
    }
    
    deinit {
        removeObservers()
        NotificationCenter.default.removeObserver(self)
    }
    
    
    
   
    
    // MARK: - GET METHODS
    
    func getCleaning(withId cleaningId:String, handler: @escaping (_: Cleaning?)->Void) {
        if let activeCleaning = activeCleanings[cleaningId] {
            handler(activeCleaning)
            return
        } else if let pastCleaning = pastCleanings[cleaningId] {
            handler(pastCleaning)
            return
        }
        
        let reference = dataManager.rootRef.child("\(Cleaning.rootDatabasePath)/\(cleaningId)")
        dataManager.getObject(fromReference: reference, handler: { [unowned self] (cleaning) in
            if cleaning != nil {
                if cleaning!.startAt > self.pivotDate! {
                    self.activeCleanings[cleaning!.ID] = cleaning!
                } else {
                    self.pastCleanings[cleaning!.ID] = cleaning!
                }
            }
            handler(cleaning)
        } as (_:Cleaning?)->Void)
    }
    
    func getCleanings(filter: CleaningFilter, with handler: @escaping (_:[Cleaning]) -> Void) {
        var refCleanings: FIRDatabaseQuery = dataManager.rootRef.child(Cleaning.rootDatabasePath)
        
        switch filter {
        case .active:
            refCleanings = refCleanings.queryOrdered(byChild: "startAt").queryStarting(atValue: pivotDate!.timeIntervalSince1970)
        case .past:
            refCleanings = refCleanings.queryOrdered(byChild: "startAt").queryEnding(atValue: pivotDate!.timeIntervalSince1970)
        default:
            break
        }
        
        dataManager.getObjects(fromReference: refCleanings, handler: handler)
    }
    
    func getCleanings(withIds ids: [String], handler: @escaping (_:[Cleaning]) -> Void) {
        var cleanings = [Cleaning]()
        
        var cleaningsCount = ids.count
        var currentCleaningsCount = 0
        
        for id in ids {
            getCleaning(withId: id, handler: { (cleaning) in
                if cleaning != nil {
                    cleanings.append(cleaning!)
                    currentCleaningsCount += 1
                } else {
                    cleaningsCount -= 1
                }
                if currentCleaningsCount == cleaningsCount {
                    handler(cleanings)
                }
            })
        }
    }
    
    
    // MARK: - MODIFY METHODS
    
    func createCleaning(_ cleaning:Cleaning, byCoordinator user:User) {
        let cleaningsRootRef = dataManager.rootRef.child(Cleaning.rootDatabasePath)
        let cleaningId = cleaningsRootRef.childByAutoId().key
        var cleaning = cleaning
        
        cleaning.ID = cleaningId
        dataManager.createObject(cleaning)
        addMember(user, toCleaning: cleaning, as: .coordinator)
    }
    
    func addMember(_ user:User, toCleaning cleaning: Cleaning, as memberType: UserRole) {
        updateMember(user, withCleaning: cleaning, as: memberType, add: true)
    }
    
    
    func removeMember(_ user:User, fromCleaning cleaning: Cleaning, as memberType: UserRole) {
        updateMember(user, withCleaning: cleaning, as: memberType, add: false)
    }
    
    private func updateMember(_ user:User, withCleaning cleaning: Cleaning, as memberType: UserRole, add: Bool) {
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
        
        let userUpdatePath = "\(User.rootDatabasePath)/\(user.ID)/\(userPath)/\(cleaning.ID)"
        let cleaningUpdatePath = "\(Cleaning.rootDatabasePath)/\(cleaning.ID)/\(cleaningPath)/\(user.ID)"
        
        let value:Any = add ? true : NSNull()
        let valuesForUpdate = [userUpdatePath : value,
                               cleaningUpdatePath : value]
        
        dataManager.updateObjects(valuesForUpdate)
    }
    
    // MARK: - OBSERVER METHODS
    
    private func addObservers() {
        
        if activeCleaningsRef == nil {
            dataManager.setPivotDate(completion: { [unowned self] (date) in
                if date == nil {
                    return
                }
                self.addObservers()
                
                NotificationCenter.default.addObserver(self, selector: #selector(self.pivotDateChangeHandler),
                                                       name: kDataManagerPivotDateChangedNotification,
                                                       object: nil)
                
            })
            return
        }
        print("CleaningsManager: add observers")
        
        if UsersManager.defaultManager.currentUser == nil {
            UsersManager.defaultManager.getCurrentUser(handler: { (user) in
                if user != nil {
                    print(user!)
                }
            })
        }
        if let cleanings = UsersManager.defaultManager.currentUserPastCleanings {
            print("USER cleanings: \(cleanings)")
        }
        
        addHandler = activeCleaningsRef!.observe(.childAdded, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String : Any], let cleaning = Cleaning(data: data) {
                self.activeCleanings[cleaning.ID] = cleaning
                
                let addNotification = Notification(name: kCleaningsManagerCleaningAddNotification,
                                                   object: self,
                                                   userInfo: [kCleaningsManagerCleaningKey : cleaning])
                
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(addNotification)
                self.postDelayedNotification(modifyNotification)
            }
        })
        
        removeHandler = activeCleaningsRef!.observe(.childRemoved, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String : Any], let cleaning = Cleaning(data: data) {
                self.activeCleanings.removeValue(forKey: cleaning.ID)
                
                let removeNotification = Notification(name: kCleaningsManagerCleaningRemoveNotification,
                                                      object: self,
                                                      userInfo: [kCleaningsManagerCleaningKey : cleaning])
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(removeNotification)
                self.postDelayedNotification(modifyNotification)
                
            }
        })
        
        changeHandler = activeCleaningsRef!.observe(.childChanged, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String : Any], let cleaning = Cleaning(data: data) {
                self.activeCleanings.updateValue(cleaning, forKey: cleaning.ID)
                
                let changeNotification = Notification(name: kCleaningsManagerCleaningChangeNotification,
                                                      object: self,
                                                      userInfo: [kCleaningsManagerCleaningKey : cleaning])
                
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(changeNotification)
                self.postDelayedNotification(modifyNotification)
            }
        })
        
        
    }
    
    private func removeObservers() {
        if addHandler != nil { activeCleaningsRef?.removeObserver(withHandle: addHandler!) }
        if changeHandler != nil { activeCleaningsRef?.removeObserver(withHandle: changeHandler!) }
        if removeHandler != nil { activeCleaningsRef?.removeObserver(withHandle: removeHandler!) }
    }

    
    // MARK: - NOTIFICATIONS
    
    private func postDelayedNotification(_ notification: Notification) {
        let timeInterval = 0.3
        if let timer = self.timer {
            timer.invalidate()
        }
        if #available(iOS 10.0, *) {
            self.timer = Timer.scheduledTimer(withTimeInterval: timeInterval, repeats: false, block: { (timer) in
                NotificationCenter.default.post(notification)
            })
        } else {
            self.timer = Timer.scheduledTimer(timeInterval: timeInterval, target: self,
                                              selector: #selector(self.rawPostNotification),
                                              userInfo: notification,
                                              repeats: false)
            
        }
    }
    
    @objc private func rawPostNotification(_ timer:Timer) {
        if let notification = timer.userInfo as? Notification {
            NotificationCenter.default.post(notification)
        }
    }
    
    @objc private func pivotDateChangeHandler(notification: Notification) {
        activeCleanings.removeAll()
        let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
        self.postDelayedNotification(modifyNotification)
        addObservers()
    }
}

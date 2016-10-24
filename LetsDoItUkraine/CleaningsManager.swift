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
        guard let id = data["id"] as? String, let addr = data["address"] as? String else {
            return nil
        }
        
        ID = id
        address = addr
        
        datetime = (data["dateTime"] as? String)?.date() ?? nil
        
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
    
    var dictionary: [String : Any] {
        var data: [String : Any] = ["id"        : ID,
                                    "active"    : isActive,
                                    "latitude"  : coordinate.latitude,
                                    "longitude" : coordinate.longitude,
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
    
    static var rootDatabasePath: String = "cleanings"
}

enum CleaningFilter {
    case all, active, past
}

enum ClenaingMembersFilter {
    case coordinator, cleaner
}

let kCleaningsManagerCleaningAddNotification:NSNotification.Name = NSNotification.Name("kCleaningsManagerCleaningAddNotification")
let kCleaningsManagerCleaningChangeNotification:NSNotification.Name = NSNotification.Name("kCleaningsManagerCleaningChangeNotification")
let kCleaningsManagerCleaningRemoveNotification:NSNotification.Name = NSNotification.Name("kCleaningsManagerCleaningRemoveNotification")
let kCleaningsManagerCleaningModifyNotification:NSNotification.Name = NSNotification.Name("kCleaningsManagerCleaningModifyNotification")

let kCleaningsManagerCleaningKey = "kCleaningsManagerCleaningKey"

class CleaningsManager {
    
    static let defaultManager = CleaningsManager()
    private var dataManager = DataManager.sharedManager
    
    var activeCleanings = [String:Cleaning]()
    private var pastCleanings = [String:Cleaning]()
    
    private lazy var activeCleaningsRef: FIRDatabaseQuery = {
        return DataManager.sharedManager.rootRef.child(Cleaning.rootDatabasePath).queryOrdered(byChild: "active").queryEqual(toValue: true)}()
    
    private var addHandler: FIRDatabaseHandle?
    private var changeHandler: FIRDatabaseHandle?
    private var removeHandler: FIRDatabaseHandle?
   
    private var timer:Timer?
    
    private var observersCount:Int = 0 {
        willSet {
            if newValue < 0 {
                return
            }
        }
        didSet {
            if observersCount == 0 {
                print("removeObservers")
                removeObservers()
                activeCleanings.removeAll()
            } else if oldValue == 0 {
                print("addObservers")
                addObservers()
            }
        }
    }
    
    // MARK: - OBSERVER METHODS
    
    func retainObserver() {
        observersCount += 1
    }
    
    func releaseObserver() {
        observersCount -= 1
    }
    
    private func addObservers() {
        
        addHandler = activeCleaningsRef.observe(.childAdded, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String:Any], let cleaning = Cleaning.init(data: data) {
                self.activeCleanings[cleaning.ID] = cleaning
                
                let addNotification = Notification(name: kCleaningsManagerCleaningAddNotification,
                                                object: self,
                                                userInfo: [kCleaningsManagerCleaningKey : cleaning])
                
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(addNotification)
                self.postDelayedNotification(modifyNotification)
            }
        }, withCancel: { (error) in
            print(error.localizedDescription)
        })
        
        removeHandler = activeCleaningsRef.observe(.childRemoved, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String:Any], let cleaning = Cleaning.init(data: data) {
                self.activeCleanings.removeValue(forKey: cleaning.ID)
                
                let removeNotification = Notification(name: kCleaningsManagerCleaningRemoveNotification,
                                                object: self,
                                                userInfo: [kCleaningsManagerCleaningKey : cleaning])
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(removeNotification)
                self.postDelayedNotification(modifyNotification)
                
            }
            }, withCancel: { (error) in
                print(error.localizedDescription)
        })
        
        changeHandler = activeCleaningsRef.observe(.childChanged, with: { [unowned self] (snapshot) in
            if let data = snapshot.value as? [String:Any], let cleaning = Cleaning(data: data) {
                self.activeCleanings.updateValue(cleaning, forKey: cleaning.ID)
                
                let changeNotification = Notification(name: kCleaningsManagerCleaningChangeNotification,
                                                object: self,
                                                userInfo: [kCleaningsManagerCleaningKey : cleaning])
                
                let modifyNotification = Notification(name: kCleaningsManagerCleaningModifyNotification)
                
                NotificationCenter.default.post(changeNotification)
                self.postDelayedNotification(modifyNotification)
            }
            }, withCancel: { (error) in
                print(error.localizedDescription)
        })
        
    }
    
    private func removeObservers() {
        if addHandler != nil { activeCleaningsRef.removeObserver(withHandle: addHandler!) }
        if changeHandler != nil { activeCleaningsRef.removeObserver(withHandle: changeHandler!) }
        if removeHandler != nil { activeCleaningsRef.removeObserver(withHandle: removeHandler!) }
    }
    
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
                if cleaning!.isActive {
                    self.activeCleanings[cleaning!.ID] = cleaning!
                } else {
                    self.pastCleanings[cleaning!.ID] = cleaning!
                }
            }
            handler(cleaning)
        } as (_:Cleaning?)->Void)
    }
    
    func getCleanings(filer: CleaningFilter, with handler: @escaping (_:[Cleaning]) -> Void) {
        var refCleanings: FIRDatabaseQuery = dataManager.rootRef.child(Cleaning.rootDatabasePath)
        
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
        
        let userUpdatePath = "users/\(user.ID)/\(userPath)/\(cleaning.ID)"
        let cleaningUpdatePath = "cleanings/\(cleaning.ID)/\(cleaningPath)/\(user.ID)"
        
        let value:Any = add ? true : NSNull()
        let valuesForUpdate = [userUpdatePath : value,
                               cleaningUpdatePath : value]
        
        dataManager.updateObjects(valuesForUpdate)
    }
}

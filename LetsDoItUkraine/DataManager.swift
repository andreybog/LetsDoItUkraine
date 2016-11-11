//
//  DataManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/8/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase

let kDatabaseDateFormat:String = "yyyy-MM-dd'T'HH:mm:ss'Z'00"
let kForbiddenPathCharacterSet = CharacterSet(charactersIn:".#$[]")

extension String {
  func date(withFormat format:String = kDatabaseDateFormat) -> Date? {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(abbreviation: "UTC")
    formatter.dateFormat = format
    
    return formatter.date(from: self)
  }
}

extension Date {
    func string(withFormat format:String = kDatabaseDateFormat) -> String? {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(abbreviation: "UTC")
        formatter.dateFormat = format
        
        return formatter.string(from: self)
    }
}

protocol FirebaseInitable {
    init?(data: [String : Any])
    var toJSON: [String : Any] { get }
    var ref: FIRDatabaseReference { get }
    static var rootDatabasePath: String { get }
}

let kDataManagerPivotDateChangedNotification = Notification.Name("kDataManagerPivotDateChangedNotification")

class DataManager {
//    static let sharedManager = DataManager()
    static private(set) var sharedManager: DataManager = {
        return DataManager()
    }()
    
    private(set)var pivotDate: Date? {
        didSet {
            NotificationCenter.default.post(Notification(name: kDataManagerPivotDateChangedNotification))
        }
    }
    
    var pivotDateHandler:FIRDatabaseHandle?
    var pivotDateAddHandler:FIRDatabaseHandle?
    
    lazy var rootRef:FIRDatabaseReference = {
        FIRDatabase.database().persistenceEnabled = true
        let ref = FIRDatabase.database().reference()
        
        return ref
    }()
  
    init () {
        setPivotDate { date in }
    }
    
    deinit {
        if pivotDateHandler != nil { rootRef.child("date/pivotDate").removeObserver(withHandle: pivotDateHandler!) }
    }
    
    // MARK: - Pivot date configuration
    
    func setPivotDate(completion: @escaping (_:Date?)->Void) {
        if pivotDate != nil {
            completion(pivotDate)
            return
        }
        
        let pivotDateRef = rootRef.child("date/pivotDate/_zap_data_last_live_poll")
        pivotDateRef.observeSingleEvent(of: .value, with: { [weak self] (snap) in
            if let val = snap.value as? Double {
                let pivotDate = Date(timeIntervalSince1970: val)
                self?.pivotDate = pivotDate
                completion(pivotDate)
            } else {
                print("DATABASE ERROR: Can't get pivot date")
            }
        })
        pivotDateHandler = pivotDateRef.observe(.value, with: { [weak self] (snap) in
            if let val = snap.value as? Double {
                self?.pivotDate = Date(timeIntervalSince1970: val)
            } else {
                print("DATABASE ERROR: Can't get pivot date")
            }
        })
    }
    
    // MARK: - API - GET
    
    func getObject<T:FirebaseInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:T?)->Void) {
        reference.observeSingleEvent(of: .value, with: { (snapshot) in
            var object:T?
            
            if let data = snapshot.value as? [String : Any] {
                object = T(data: data)
            }
            
            handler(object)
        })
    }
    
    func getObjects<T:FirebaseInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:[T]) -> Void) {
        
        reference.observeSingleEvent(of: .value, with: { [unowned self] (snapshots) in
            var objects = [T]()
            
            var childrensCount = snapshots.childrenCount
            var currentObjectsCount: UInt = 0
            
            if childrensCount == 0 {
                return handler(objects)
            }
            
            // get objects ids
            for snapshot in snapshots.children {
                guard let snap = snapshot as? FIRDataSnapshot else {
                    childrensCount -= 1
                    continue
                }
            
                let objectRef = self.rootRef.child("\(T.rootDatabasePath)/\(snap.key)")
                
                // get objects from ids
                self.getObject(fromReference: objectRef, handler: { (object) in
                    if object != nil {
                        objects.append(object!)
                        currentObjectsCount += 1
                    } else {
                        childrensCount -= 1
                    }
                    if currentObjectsCount == childrensCount {
                        handler(objects)
                    }
                    
                    } as (_:T?)->Void )
            }
        })
    }
    
    func getObjectsCount(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:UInt) -> Void) {
        reference.observeSingleEvent(of: .value, with: { (snapshots) in
            handler(snapshots.childrenCount)
        })
    }
    
    func getObjects<T:FirebaseInitable>(withIds ids:[String], handler: @escaping (_:[T]) -> Void) {
        var objects = [T]()
        let objectsRootPath = T.rootDatabasePath
        var objectsCount = ids.count
        var currentObjectsCount: Int = 0
        
        if objectsCount == 0 {
            return handler(objects)
        }
        
        for id in ids {
            let objectRef = self.rootRef.child("\(objectsRootPath)/\(id)")
            
            // get objects from ids
            self.getObject(fromReference: objectRef, handler: { (object) in
                if object != nil {
                    objects.append(object!)
                    currentObjectsCount += 1
                } else {
                    objectsCount -= 1
                }
                if currentObjectsCount == objectsCount {
                    handler(objects)
                }
                
                } as (_:T?)->Void )
        }
        
    }
    
    // MARK: - API - UPDATE
    
    func createObject<T:FirebaseInitable>(_ object:T, withCompletionBlock block: @escaping (_: Error?, _: FIRDatabaseReference) -> Void) {
        let reference = rootRef.child(T.rootDatabasePath)
//        reference.updateChildValues(object.toJSON)
        reference.updateChildValues(object.toJSON, withCompletionBlock: block)
    }
    
    func updateObjects(_ values: [String : Any]) {
        rootRef.updateChildValues(values)
    }
    
    // MARK: - API - ADD OBSERVERS
    
    func addObserver<T:FirebaseInitable>(toReference ref:FIRDatabaseQuery, onEvent event: FIRDataEventType, handler: @escaping (_:T?)->Void) -> FIRDatabaseHandle {
        return ref.observe(event, with: { (snapshot) in
            if let data = snapshot.value as? [String : Any] {
                handler(T(data:data))
            } else {
                handler(nil)
            }
        })
    }
}

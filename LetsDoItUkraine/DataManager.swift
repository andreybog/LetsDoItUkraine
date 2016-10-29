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
  init?(data: [String : Any ])
  var dictionary: [String : Any] { get }
  static var rootDatabasePath: String { get }
}

class DataManager {
  static let sharedManager = DataManager()
  
  lazy var rootRef:FIRDatabaseReference = {
//    FIRDatabase.database().persistenceEnabled = true
    
    let ref = FIRDatabase.database().reference()
    
//    self.configureUserCleanings(ref)
//    self.configureCleaningMembers(ref)
    
    return ref
  }()
  
  private var refCleaningMembers:FIRDatabaseReference!
  private var _handleCleaningMembers:FIRDatabaseHandle!
  private var refUserCleanings:FIRDatabaseReference!
  private var _handleUserCleanings:FIRDatabaseHandle!
  
  deinit {
    refCleaningMembers.removeObserver(withHandle: _handleCleaningMembers)
    refUserCleanings.removeObserver(withHandle: _handleUserCleanings)
  }
  
  // MARK: - API - GET
  
  func getObject<T:FirebaseInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:T?)->Void) {
    var object:T?
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
      if let data = snapshot.value as? [String : AnyObject] {
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
        
        for id in ids {
            let objectRef = self.rootRef.child("\(objectsRootPath)/\(id)")
            
            // get objects from ids
            self.getObject(fromReference: objectRef, handler: { (object) in
                if object != nil {
                    objects.append(object!)
                    currentObjectsCount += 1
                } else {
                    currentObjectsCount -= 1
                }
                if currentObjectsCount == objectsCount {
                    handler(objects)
                }
                
            } as (_:T?)->Void )
            
        }

    }
    
  // MARK: - API - UPDATE
  
  func createObject<T:FirebaseInitable>(_ object:T) {
    let reference = rootRef.child(T.rootDatabasePath)
    reference.updateChildValues(object.dictionary)
  }
  
  func updateObjects(_ values: [String : Any]) {
    rootRef.updateChildValues(values)
  }
  
  // MARK: - CONFIGURATION
  
  private func configureCleaningMembers(_ ref: FIRDatabaseReference) {
    refCleaningMembers = ref.child("cleaning-members")
    _handleCleaningMembers = refCleaningMembers.observe(.value, with: { (snapshot) in })
  }
  
  private func configureUserCleanings(_ ref: FIRDatabaseReference) {
    refUserCleanings = ref.child("user-cleanings")
    _handleUserCleanings = refUserCleanings.observe(.value, with: { (snapshot) in })
  }
}

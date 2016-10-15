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
  
  lazy var ref:FIRDatabaseReference = {
//    FIRDatabase.database().persistenceEnabled = true
    
    let ref = FIRDatabase.database().reference()
    
//    self.configureUserCleanings(ref)
    self.configureCleaningMembers(ref)
    
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
        let objectDictionary = [snapshot.key : data]
        object = T(data: objectDictionary)
      }
      handler(object)
    })
  }
  
  func getObjects<T:FirebaseInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:[T]) -> Void) {
    
    reference.observeSingleEvent(of: .value, with: { [unowned self] (snapshots) in
      var objects = [T]()
      
      let childrensCount = snapshots.childrenCount
      var currentIndex: UInt = 1
      
      // get objects ids
      for snapshot in snapshots.children {
        guard let snap = snapshot as? FIRDataSnapshot else {
          currentIndex += 1
          continue
        }
 
        let objectRef = self.ref.child("\(T.rootDatabasePath)/\(snap.key)")
        
        // get objects from ids
        self.getObject(fromReference: objectRef, handler: { (object) in
          if object != nil {
            objects.append(object!)
          }
          if currentIndex == childrensCount {
            handler(objects)
          }
          currentIndex += 1
          } as (_:T?)->Void )
      }
    })
  }
  
  private func configureCleaningMembers(_ ref: FIRDatabaseReference) {
    refCleaningMembers = ref.child("cleaning-members")
    _handleCleaningMembers = refCleaningMembers.observe(.value, with: { (snapshot) in })
  }
  
  private func configureUserCleanings(_ ref: FIRDatabaseReference) {
    refUserCleanings = ref.child("user-cleanings")
    _handleUserCleanings = refUserCleanings.observe(.value, with: { (snapshot) in })
  }
}

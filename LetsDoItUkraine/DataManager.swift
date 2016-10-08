//
//  DataManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/8/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase

class DataManager {
  private static let _sharedManager = DataManager()
  
  private lazy var ref:FIRDatabaseReference = {
    FIRDatabase.database().persistenceEnabled = true
    
    let ref = FIRDatabase.database().reference()
    
    self.configureUserCleanings(ref)
    self.configureCoordinatorCleanings(ref)
    
    return ref
  }()
  
  private var refCoordinatorCleanings:FIRDatabaseReference!
  private var _handleCoordinatorCleanings:FIRDatabaseHandle!
  private var refUserCleanings:FIRDatabaseReference!
  private var _handleUserCleanings:FIRDatabaseHandle!
  
  static func sharedManager() -> DataManager {
    return _sharedManager
  }
  
  deinit {
    refCoordinatorCleanings.removeObserver(withHandle: _handleCoordinatorCleanings)
    refUserCleanings.removeObserver(withHandle: _handleUserCleanings)
  }
  
  // MARK: - API - GET
  
  func getAllCleanings(with handler: @escaping (_:[Cleaning]) -> Void) {
    let refCleanings = ref.child("cleanings")
    
    refCleanings.observeSingleEvent(of: .value, with: { (snapshots) in
      var cleanings = [Cleaning]()
      
      for snapshot in snapshots.children {
        if let snap = snapshot as? FIRDataSnapshot {
          let cleaning = Cleaning(withId:snap.key, data: snap.value as! [String : AnyObject])
          cleanings.append(cleaning)
        }
      }
      handler(cleanings)
    })
  }
  
  func getCleaning(withId cleaningId:String, onSuccess success: @escaping (_: Cleaning?)->Void) {
    let refCleaning = ref.child("cleanings/\(cleaningId)")
    var cleaning:Cleaning?
    
    refCleaning.observeSingleEvent(of: .value, with: { (snapshot) in
      if let data = snapshot.value as? [String : AnyObject] {
        cleaning = Cleaning(withId: snapshot.key, data: data)
      }
      success(cleaning)
    })
  }
  
  func isUserCoordinator(userId: String, handler: @escaping (_:Bool, _ cleaningsIds:[String]) -> Void) {
    queryHandler(nodePath: "coordinator-cleanings", childKey: "coordinator", value: userId, handler: handler)
  }

  func cleaningHasCoordinators(cleaningId: String, handler: @escaping (_:Bool, _ userIds:[String]) -> Void) {
    queryHandler(nodePath: "coordinator-cleanings", childKey: "cleaning", value: cleaningId, handler: handler)
  }
  
  func cleaningHasCleaners(cleaningId: String, handler: @escaping (_:Bool, _ userIds:[String]) -> Void) {
    queryHandler(nodePath: "user-cleanings", childKey: "cleaning", value: cleaningId, handler: handler)
  }
  
  func userHasCleanings(userId: String, handler: @escaping (_:Bool, _ cleaningsIds:[String]) -> Void) {
    queryHandler(nodePath: "user-cleanings", childKey: "user", value: userId, handler: handler)
  }
  
  private func queryHandler(nodePath:String, childKey: String, value: String, handler: @escaping (_:Bool, _:[String]) -> Void) {
    let query = ref.child(nodePath).queryOrdered(byChild: childKey).queryEqual(toValue: value)
    
    query.observeSingleEvent(of: .value, with: { (snapshots) in
      if !snapshots.hasChildren() {
        handler(false, [])
        return
      }
      
      var ids = [String]()
      
      for snapshot in snapshots.children {
        if let snap = snapshot as? FIRDataSnapshot {
          let id = (snap.value as! [String : AnyObject])["cleaning"] as! String
          ids.append(id)
        }
      }
      handler(true, ids)
    })
  }
  
  // MARK: - API - ADD
  
  // MARK: - Configuration
  
  func configureCoordinatorCleanings(_ ref: FIRDatabaseReference) {
    refCoordinatorCleanings = ref.child("coordinator-cleanings")
    _handleCoordinatorCleanings = refCoordinatorCleanings.observe(.value, with: { (snapshot) in })
  }
  
  func configureUserCleanings(_ ref: FIRDatabaseReference) {
    refUserCleanings = ref.child("user-cleanings")
    _handleUserCleanings = refUserCleanings.observe(.value, with: { (snapshot) in })
  }
}

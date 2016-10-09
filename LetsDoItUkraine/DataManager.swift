//
//  DataManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/8/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase

enum CleaningFiler {
  case all
  case active
  case past
}

enum UserClenaingsFilter {
  case asModerator
  case asCleaner
  case past
}

enum ClenaingMembersFilter {
  case coordinator
  case cleaner
}

class DataManager {
  private static let _sharedManager = DataManager()
  
  private lazy var ref:FIRDatabaseReference = {
    FIRDatabase.database().persistenceEnabled = true
    
    let ref = FIRDatabase.database().reference()
    
    self.configureUserCleanings(ref)
    self.configureCleaningMembers(ref)
    
    return ref
  }()
  
  private var refCleaningMembers:FIRDatabaseReference!
  private var _handleCleaningMembers:FIRDatabaseHandle!
  private var refUserCleanings:FIRDatabaseReference!
  private var _handleUserCleanings:FIRDatabaseHandle!
  
  static func sharedManager() -> DataManager {
    return _sharedManager
  }
  
  deinit {
    refCleaningMembers.removeObserver(withHandle: _handleCleaningMembers)
    refUserCleanings.removeObserver(withHandle: _handleUserCleanings)
  }
  
  // MARK: - API - GET
  
  private func getObject<T:DictionaryInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:T?)->Void) {
    var object:T?
    
    reference.observeSingleEvent(of: .value, with: { (snapshot) in
      if let data = snapshot.value as? [String : AnyObject] {
        object = T(withId: snapshot.key, data: data)
      }
      handler(object)
    })
  }
  
  private func getObjects<T:DictionaryInitable>(fromReference reference:FIRDatabaseQuery, handler: @escaping (_:[T]) -> Void) {
    
    reference.observeSingleEvent(of: .value, with: { [unowned self] (snapshots) in
      var objects = [T]()
      
      let childrensCount = snapshots.childrenCount
      var currentIndex: UInt = 1
      
      // get objects ids
      for snapshot in snapshots.children {
        guard let snap = snapshot as? FIRDataSnapshot else { continue }
        var objectRef:FIRDatabaseReference!
        
        switch T.self {
        case is User.Type:
          objectRef = self.ref.child("users/\(snap.key)")
        case is Cleaning.Type:
          objectRef = self.ref.child("cleanings/\(snap.key)")
        case is RecycleCategory.Type:
          objectRef = self.ref.child("recycleCategories/\(snap.key)")
        case is RecyclePoint.Type:
          objectRef = self.ref.child("recyclePoints/\(snap.key)")
        case is News.Type:
          objectRef = self.ref.child("news/\(snap.key)")
        default:
          currentIndex += 1
          continue
        }
        
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
  
  
  /*** getting users ***/
  
  func getUser(withId userId:String, handler: @escaping (_: User?)->Void) {
    let refUser = ref.child("users/\(userId)")
    self.getObject(fromReference: refUser, handler: handler)
  }
  
  func getCleaningMembers(cleaningId: String, filter: ClenaingMembersFilter, handler: @escaping (_:[User]) -> Void) {
    var refPath = "cleaning-members/\(cleaningId)"
    
    switch filter {
    case .coordinator:    refPath.append("/coordinators")
    case .cleaner:        refPath.append("/cleaners")
    }
    let reference = ref.child(refPath)
    
    self.getObjects(fromReference: reference, handler: handler)
  }
  
  
  
  /*** getting cleanings ***/
  
  func getCleaning(withId cleaningId:String, handler: @escaping (_: Cleaning?)->Void) {
    let refCleaning = ref.child("cleanings/\(cleaningId)")
    self.getObject(fromReference: refCleaning,handler: handler)
  }
  
  func getUserCleanings(userId: String, filter: UserClenaingsFilter, handler: @escaping (_:[Cleaning]) -> Void) {
    var refPath = "user-cleanings/\(userId)"
    
    switch filter {
      case .asModerator:  refPath.append("/asModerator")
      case .asCleaner:    refPath.append("/asCleaner")
      case .past:         refPath.append("/past")
    }
    let reference = ref.child(refPath)
    
    self.getObjects(fromReference: reference, handler: handler)
  }
  
  func getCleanings(filer: CleaningFiler, with handler: @escaping (_:[Cleaning]) -> Void) {
    var refCleanings:FIRDatabaseQuery = ref.child("cleanings")
    
    switch filer {
    case .active:
      refCleanings = refCleanings.queryOrdered(byChild: "active").queryEqual(toValue: true)
    case .past:
      refCleanings = refCleanings.queryOrdered(byChild: "active").queryEqual(toValue: false)
    default:
      break
    }
    
    self.getObjects(fromReference: refCleanings, handler: handler)
  }
  
  /*** getting recycle categories ***/
  
  func getRecylceCategory(withId categoryId:String, handler: @escaping (_:RecycleCategory?) -> Void) {
    let refCategory = ref.child("recycleCategories/\(categoryId)")
    self.getObject(fromReference: refCategory, handler: handler)
  }
  
  func getAllRecycleCategories(with handler: @escaping (_:[RecycleCategory]) -> Void) {
    let refCategories = ref.child("recycleCategories")
    self.getObjects(fromReference: refCategories, handler: handler)
  }
  
  
  /*** getting recycle points ***/
  
  func getRecylcePoint(withId pointId:String, handler: @escaping (_:RecyclePoint?) -> Void) {
    let refPoint = ref.child("recyclePoints/\(pointId)")
    self.getObject(fromReference: refPoint, handler: handler)
  }
  
  func getAllRecyclePoints(with handler: @escaping (_:[RecyclePoint]) -> Void) {
    let refPoints = ref.child("recyclePoints")
    self.getObjects(fromReference: refPoints, handler: handler)
  }
  
  /*** getting news ***/
  
  func getNews(withId newsId:String, handler: @escaping (_:News?) -> Void) {
    let refNews = ref.child("news/\(newsId)")
    self.getObject(fromReference: refNews, handler: handler)
  }
  
  func getAllNews(with handler: @escaping (_:[RecyclePoint]) -> Void) {
    let refNews = ref.child("news")
    self.getObjects(fromReference: refNews, handler: handler)
  }
  
  // TODO: - API - ADD
  
  // TODO: - API - Remove
  
  // TODO: - API - Update
  
  // MARK: - Configuration
  
  private func configureCleaningMembers(_ ref: FIRDatabaseReference) {
    refCleaningMembers = ref.child("cleaning-members")
    _handleCleaningMembers = refCleaningMembers.observe(.value, with: { (snapshot) in })
  }
  
  private func configureUserCleanings(_ ref: FIRDatabaseReference) {
    refUserCleanings = ref.child("user-cleanings")
    _handleUserCleanings = refUserCleanings.observe(.value, with: { (snapshot) in })
  }
}

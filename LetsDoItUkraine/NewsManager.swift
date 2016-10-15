//
//  NewsManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

extension News : FirebaseInitable {
  init?(data: [String : Any ]) {
    guard let key = data.keys.first, let data = data[key] as? [String : Any] else { return nil }
    
    ID = key
    title = data["title"] as! String
    body = data["body"] as? String
    
    if let dateString = data["datetime"] as? String {
      date = dateString.date()
    } else { date = nil }
    
    if let urlString = data["url"] as? String {
      url = URL(string: urlString)
    } else { url = nil }
    
    if let picString = data["picture"] as? String {
      picture = URL(string: picString)
    } else { picture = nil }
  }
  
  var dictionary: [String : Any]  {
    return [:]
  }
  
  static var rootDatabasePath = "news"
}

class NewsManager {
  
  static let defaultManager = NewsManager()
  private var dataManager = DataManager.sharedManager
  
  
  func getNews(withId newsId:String, handler: @escaping (_:News?) -> Void) {
    let refNews = dataManager.ref.child("news/\(newsId)")
    dataManager.getObject(fromReference: refNews, handler: handler)
  }
  
  func getAllNews(with handler: @escaping (_:[RecyclePoint]) -> Void) {
    let refNews = dataManager.ref.child("news")
    dataManager.getObjects(fromReference: refNews, handler: handler)
  }
}

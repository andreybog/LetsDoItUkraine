//
//  NewsManager.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/11/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import Firebase
extension News : FirebaseInitable {
    init?(data: [String : Any]) {
        
        guard let id = data["id"] as? String, let title = data["title"] as? String else {
            return nil
        }
        
        ID = id
        self.title = title
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
    
    var toJSON: [String : Any]  {
        var data = ["id"    : ID,
                    "title" : title]
        
        if let body = body { data["body"] = body }
        if let date = date { data["datetime"] = date.string() }
        if let url = url { data["url"] = url.absoluteString }
        if let picture = picture { data["picture"] = picture.absoluteString }
        
        return [ID : data]
    }
    
    var ref:FIRDatabaseReference {
        return NewsManager.defaultManager.dataManager.rootRef.child("\(News.rootDatabasePath)/\(ID)")
    }
    
    static var rootDatabasePath = "news"
}

class NewsManager {
    
    static let defaultManager = NewsManager()
    fileprivate var dataManager = DataManager.sharedManager
    
    // MARK: - GET METHODS
    
    func getNews(withId newsId:String, handler: @escaping (_:News?) -> Void) {
        let refNews = dataManager.rootRef.child("\(News.rootDatabasePath)/\(newsId)")
        dataManager.getObject(fromReference: refNews, handler: handler)
    }
    
    func getAllNews(with handler: @escaping (_:[News]) -> Void) {
        let refNews = dataManager.rootRef.child(News.rootDatabasePath)
        dataManager.getObjects(fromReference: refNews, handler: handler)
    }
    
    // MARK: - GET METHODS
    
    func createNews(_ news: News) {
        let newsRootRef = dataManager.rootRef.child(News.rootDatabasePath)
        let newsId = newsRootRef.childByAutoId().key
        var news = news
        
        news.ID = newsId
        dataManager.createObject(news)
    }
}

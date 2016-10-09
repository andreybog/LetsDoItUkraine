//
//  News.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

struct News : DictionaryInitable, CustomDebugStringConvertible {
    var ID: String
    var title: String
    var body: String?
    var date: String
    var url: NSURL?
    var picture: NSURL?
  
  var debugDescription: String {
    return "NEWS: - \(ID) - \(title)"
  }
		
    
  init(withId newId:String, data: [String: AnyObject]) {
    ID = newId
    title = data["title"] as! String
    body = data["body"] as? String
    date = data["date"] as! String
    
    if let urlString = data["url"] as? String {
      url = NSURL(string: urlString)
    }
    
    if let picDict = data["picture"] as? [String:AnyObject],
      let urlString = picDict["url"] as? String {
      picture = NSURL(string: urlString)
    }
  }
}

//
//  RecycleCategory.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation



struct RecycleCategory : DictionaryInitable, Hashable, CustomDebugStringConvertible {
    var ID: String
    var title: String
    var picture: NSURL?
  
  var debugDescription: String {
    return "RECYCLE CATEGORY: \(ID) - \(title)"
  }
  
  var hashValue: Int {
    return ID.hash ^ title.hash
  }
	
  
  init(withId newId:String, data: [String: AnyObject]) {
    ID = newId
    title = data["title"] as! String
    
    if let picDict = data["picture"] as? [String:AnyObject],
      let urlString = picDict["url"] as? String {
        picture = NSURL(string: urlString)
    }
  }
}

func == (category1:RecycleCategory, category2:RecycleCategory) -> Bool {
  return category1.ID == category2.ID && category1.title == category2.title
}

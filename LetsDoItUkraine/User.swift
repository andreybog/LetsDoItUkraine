//
//  User.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation


struct User : DictionaryInitable, CustomDebugStringConvertible {
    var ID: String
    var firstName: String
    var lastName: String
    var phone: String?
    var email: String?
    var photo: NSURL?
    var country: String?
    var city: String?
  
  var debugDescription: String {
    return "USER: - \(ID) - \(firstName) \(lastName)"
  }
  
  init(withId newId: String, data: [String: AnyObject]) {
    ID = newId
    firstName = data["firstName"] as! String
    lastName = data["lastName"] as! String
    phone = data["phone"] as? String
    country = data["country"] as? String
    city = data["city"] as? String
    email = data["email"] as? String
    
    if let pictureDict = data["pictures"] as? [String : String],
      let picUrl = pictureDict["url"] {
      photo = NSURL(string:picUrl)
    }
  }
  
}

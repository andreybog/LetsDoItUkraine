//
//  User.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation


struct User {
    var ID: Int
    var firstName: String
    var lastName: String
    var phone: String
    var email: String
    var photo: NSURL?
    var country: String
    var city: String
    
    init(data: [String: AnyObject]) {
        ID = data["id"] as! Int
        firstName = data["firstName"] as! String
        lastName = data["lastName"] as! String
        phone = data["phone"] as! String
        country = data["country"] as! String
        city = data["city"] as! String
        email = data["email"] as! String
        photo = NSURL(string: data["photo"] as! String)
    }
    
}

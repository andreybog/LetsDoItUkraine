//
//  User.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation


struct User : CustomStringConvertible {
    var ID: String
    var firstName: String
    var lastName: String?
    var phone: String?
    var email: String?
    var photo: URL?
    var country: String?
    var city: String?
  
  var description: String {
    let lastName = self.lastName ?? ""
    let email = self.email ?? ""
    let phone = self.phone ?? ""
    let country = self.country ?? ""
    let city = self.city ?? ""
    
    return "USER: - \(ID) - \(firstName) \(lastName)\n" +
            "email: \(email)\tphone: \(phone)\n" +
            "\(country)/t\(city)"
  }
  
  init() {
    ID = ""
    firstName = ""
  }
}

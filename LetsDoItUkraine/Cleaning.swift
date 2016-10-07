//
//  Cleaning.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

struct Cleaning {
    var ID: Int
    var adress: String
    var pictures: [NSURL]
    var date: String
    var description: String
    var isActive: Bool
    
    init(data: [String: AnyObject]) {
        ID = data["id"] as! Int
        adress = data["adress"] as! String
        pictures = [NSURL(string: data["pictures"] as! String)!]
        date = data["date"] as! String
        description = data["description"] as! String
        isActive = data["isActive"] as! Bool
    }
}

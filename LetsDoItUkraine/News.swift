//
//  News.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

struct News {
    var title: String
    var body: String
    var date: String
    var url: NSURL
    var picture: NSURL?
    
    init(data: [String: AnyObject]) {
        title = data["title"] as! String
        body = data["body"] as! String
        date = data["date"] as! String
        url = NSURL(string:data["url"] as! String)!
        picture = NSURL(string:data["picture"] as! String)!
        
    }
}

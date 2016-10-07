//
//  RecycleCategory.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
struct RecycleCategory {
    var title: String
    var picture: NSURL
    
    init(data: [String: AnyObject]) {
        title = data["title"] as! String
        picture = NSURL(string: data["picture"] as! String)!
    }
}

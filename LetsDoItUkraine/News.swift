//
//  News.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

struct News : CustomStringConvertible {
    var ID: String
    var title: String
    var body: String?
    var date: Date?
    var url: URL?
    var picture: URL?
  
  var description: String {
    return "NEWS: - \(ID) - \(title)"
  }
}

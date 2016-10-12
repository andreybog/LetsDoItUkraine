//
//  RecycleCategory.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation



struct RecycleCategory : Hashable, CustomStringConvertible {
    var ID: String
    var title: String
    var picture: URL?
  
  var description: String {
    return "RECYCLE CATEGORY: \(ID) - \(title)"
  }
  
  var hashValue: Int {
    return ID.hash ^ title.hash
  }
  
 }

func == (category1:RecycleCategory, category2:RecycleCategory) -> Bool {
  return category1.ID == category2.ID && category1.title == category2.title
}

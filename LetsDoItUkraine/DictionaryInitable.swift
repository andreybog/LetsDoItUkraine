//
//  DictionaryInitable.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/9/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

protocol DictionaryInitable {
  init(withId newId:String, data: [String: AnyObject])
}

//
//  FiltersModel.swift
//  LetsDoItUkraine
//
//  Created by user on 24.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

class FiltersModel {
    
    static var sharedModel = FiltersModel()
    
    var categories:Set<RecyclePointCategory> = [] {
        didSet {
            UserDefaults.standard.set(Array(categories).map({$0.rawValue}), forKey: "Categories")
            UserDefaults.standard.synchronize()
        }
    }
    
    private init() {
        if let result = UserDefaults.standard.value(forKey: "Categories") as? [String] {
            self.categories = Set(result.map({ RecyclePointCategory(rawValue: $0)! }))
        }
    }
}

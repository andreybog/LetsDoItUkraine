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
    
    private init() {}
    
    func saveCategories(categories: Set<RecyclePointCategory>) {
        UserDefaults.standard.set(Array(categories).map({$0.rawValue}), forKey: "Categories")
    }
    
    func retrieveCategories() -> Set<RecyclePointCategory> {
        if let result = UserDefaults.standard.value(forKey: "Categories") as? [String] {
            return Set(result.map({r in RecyclePointCategory(rawValue: r)!}))
        } else {
            return Set<RecyclePointCategory>()
        }
    }
}

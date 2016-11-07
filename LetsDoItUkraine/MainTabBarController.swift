//
//  MainTabBarController.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 11/5/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class MainTabBarController: UITabBarController {


    
//     MARK: - Navigation

    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        if let index = tabBar.items?.index(of: item), index == 1  {
            print("In contacts")
            
            // for testing
//            CleaningsManager.defaultManager.getCleaning(withId: "i02", handler: { (cleaning) in
//                if cleaning != nil {
//                    if let user = UsersManager.defaultManager.currentUser {
//                        if user.cleaningsMetadata.count == 1 {
//                            user.go(to: cleaning!)
//                        } else {
//                            user.refuse(from: cleaning!)
//                        }
//
//                    }
//                }
//            })
            
        }
    }
}

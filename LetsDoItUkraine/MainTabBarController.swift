//
//  MainTabBarController.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 11/5/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Firebase

class MainTabBarController: UITabBarController, UITabBarControllerDelegate {

//    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
//        if let index = tabBar.items?.index(of: item), index == 4  {
//            
//            print("hello")
//            
//        }
//    }
    
    
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        
        if viewController is CreateCleaningViewController {
            if !AuthorizationUtils.isCurrentUserEnabled() {
                AuthorizationUtils.authorize(vc: self, onSuccess: {
                    self.selectedIndex = 4
                    }, onFailed: {
                        
                })
                return false
            }
            
        }
        return true
    }
}

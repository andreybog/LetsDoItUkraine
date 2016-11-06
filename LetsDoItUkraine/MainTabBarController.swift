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
            
        }
    }
}

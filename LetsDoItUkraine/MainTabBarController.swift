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
    
    var lastSelectedIndex: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        
    }
    
    override func tabBar(_ tabBar: UITabBar, didSelect item: UITabBarItem) {
        lastSelectedIndex = tabBar.items?.index(of: item)
    }
    
    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let nav = viewController as? UINavigationController, let rootVc = nav.viewControllers.first {
            if rootVc is CreateCleaningViewController || rootVc is UserProfileViewController, !AuthorizationUtils.isCurrentUserEnabled() {
                
                AuthorizationUtils.authorize(vc: self, onSuccess: { [unowned self] in
                    if let index = self.lastSelectedIndex {
                        self.selectedIndex = index
                    }
                }, onFailed: {
                })
                
                return false
            }
        }
        return true
    }
    
    func showMessageToUser(_ message: String, title: String) {
        let alert = UIAlertController(title: title , message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
}

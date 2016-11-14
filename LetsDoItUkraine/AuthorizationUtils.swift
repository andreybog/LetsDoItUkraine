//
//  AuthorizationUtils.swift
//  LetsDoItUkraine
//
//  Created by user on 06.11.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class AuthorizationUtils {
    
    static func authorize(vc: UIViewController, onSuccess: (() -> Void)?, onFailed: (() -> Void)?) {
        
        if FIRAuth.auth()?.currentUser != nil {
            if let success = onSuccess {
                success()
            }
        } else {
            guard let authVC = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "AuthVC") as? AuthorizationViewController else { return }
            
            func wrapCallback(_ maybeCallback: (() -> Void)?) -> (() -> Void)? {
                return {
                    if let _ = vc.navigationController?.dismiss(animated: true, completion: nil) {
                        
                    } else if let tabBar = vc as? UITabBarController {
                        tabBar.dismiss(animated: true, completion: nil)
                    }
                    
                    if let callback = maybeCallback {
                        callback()
                    }
                }
            }
            
            authVC.successCallback = wrapCallback(onSuccess)
            authVC.failedCallback = wrapCallback(onFailed)
            
            if let _ = vc.navigationController?.present(authVC, animated: true, completion: nil) {
                
            } else if let tabBar = vc as? UITabBarController {
                tabBar.present(authVC, animated: true, completion: nil)
            }
            
        }
    }
    
    static func isCurrentUserEnabled() -> Bool {
        return FIRAuth.auth()?.currentUser != nil
    }
}








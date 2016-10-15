//
//  FirstViewController.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/2/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FBSDKLoginKit
import Firebase

class FirstViewController: UIViewController {

  var user:User?
  var clean:Cleaning?

  override func viewDidLoad() {
    super.viewDidLoad()

    let loginButton = FBSDKLoginButton()
    loginButton.center = view.center
    view.addSubview(loginButton)
    
    var frame = loginButton.frame
    
    frame.origin.y += 100
    let button = UIButton(frame: frame)
    button.addTarget(self, action: #selector(actionPrint), for: .touchUpInside)
    button.backgroundColor = UIColor.green
    view.addSubview(button)
    
    test()

  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }

  func test() {
    
    UsersManager.defaultManager.getUser(withId: "3", handler: { (user) in
      if user != nil {
        self.user = user
      }
    })
    CleaningsManager.defaultManager.getCleaning(withId: "3", handler: { (clean) in
      if clean != nil {
        self.clean = clean
      }
    })
  }
  
  func actionPrint() {
    if let user = user, let clean = clean {
      print("\(user)\n\(clean)")
      CleaningsManager.defaultManager.addMember(user, toCleaning: clean, as: .cleaner)
    }
  }
      
  
}
    
    





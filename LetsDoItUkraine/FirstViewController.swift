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
  
  var ref:FIRDatabaseReference!

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
<<<<<<< HEAD
    let loginButton = FBSDKLoginButton()
    loginButton.center = self.view.center
    self.view.addSubview(loginButton)
=======
    configureDatabase()
    
    ref.child("messages").childByAutoId().setValue(["name" : "Andrey", "text" : "some text"])
    
    let loginButton = FBSDKLoginButton()
    loginButton.center = view.center
    view.addSubview(loginButton)
>>>>>>> temp
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }
<<<<<<< HEAD
=======

  func configureDatabase() {
    ref = FIRDatabase.database().reference()
  }

>>>>>>> temp
}


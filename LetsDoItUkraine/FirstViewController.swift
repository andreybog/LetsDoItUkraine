//
//  FirstViewController.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/2/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FBSDKLoginKit

class FirstViewController: UIViewController {

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    let loginButton = FBSDKLoginButton()
    loginButton.center = self.view.center
    self.view.addSubview(loginButton)
  }

  override func didReceiveMemoryWarning() {
    super.didReceiveMemoryWarning()
    // Dispose of any resources that can be recreated.
  }


}


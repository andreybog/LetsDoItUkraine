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

class FirstViewController: UIViewController, FBSDKLoginButtonDelegate {
  
  let refToUsers = FIRDatabase.database().reference().child("users")
    
    @IBOutlet weak var loginFacebookButton: FBSDKLoginButton!
    

  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view, typically from a nib.
    
    loginFacebookButton.readPermissions = ["public_profile","email", "user_friends"]
    loginFacebookButton.delegate = self
  }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if let error = error {
            print(error.localizedDescription)
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let err = error {
                print(err.localizedDescription)
            } else {
                print("Got user: \(user?.displayName, user?.email, user?.photoURL)")
                self.saveUserInfoToDatabase(user: user!)
            }
        }
    }
    
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        
    }
    
    func saveUserInfoToDatabase(user: FIRUser) {
        let name = user.displayName!.components(separatedBy: "  ")
        let dict = ["firstName": name[0], "lastName": name[1], "email": user.email!, "photo": String(describing: user.photoURL!)]
        let key = refToUsers.childByAutoId().key
        refToUsers.child(key).setValue(dict)
        refToUsers.child(key).child("picture").setValue(["picId": String(describing: user.photoURL!)])
    }

}


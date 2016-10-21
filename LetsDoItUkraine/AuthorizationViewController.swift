//
//  AuthorizationViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 16.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FBSDKCoreKit
import FBSDKLoginKit
import FBSDKShareKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class AuthorizationViewController: UIViewController, FBSDKLoginButtonDelegate {
    
    
    @IBOutlet weak var loginButton: FBSDKLoginButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        loginButton.readPermissions = ["public_profile","email", "user_friends"]
        loginButton.delegate = self
        let alert = UIAlertController(title:"Авторизация" , message: "Не удалось авторизироваться с пoмошью Facebook", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        self.present(alert, animated: true, completion: nil)
    }
    
    func fetchFacebookUserForID(ID: String) {
        let params = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start {(connection, result, error) in
            if error != nil {
                self.showMessageToUser()
                return
            }
            var user = User()
            guard let data = result as? NSDictionary else { return }
            
            
            user.ID = ID
            if let firstName = data["first_name"] as? String {
                user.firstName = firstName
            }
            if let lastName = data["last_name"] as? String {
                user.lastName = lastName
            }
            if let email = data["email"] as? String {
                user.email = email
            }
            
            if let picture = data["picture"] as? NSDictionary,
                let data = picture["data"] as? NSDictionary,
                let url = data["url"] as? String {
                user.photo = URL(string: url)
            }
            let usersManager = UsersManager()
            usersManager.addUser(user)
        }
        
    }
    
    func showMessageToUser() {
        
        
        
        
        let alert = UIAlertController(title:"Авторизация" , message: "Не удалось авторизироваться с пoмошью Facebook", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        if error != nil {
            self.showMessageToUser()
            return
        }
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) { (user, error) in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            if let user = user {
                self.fetchFacebookUserForID(ID: user.uid)
            }
            
        }
    }
    
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        try! FIRAuth.auth()!.signOut()
    }
    


}

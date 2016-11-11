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
    
    
    @IBOutlet weak var messageForUser: UILabel!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    @IBOutlet weak var loginButton: FBSDKLoginButton!
    
    @IBOutlet weak var cancelButton: UIButton!
    
    var successCallback: (() -> Void)?
    var failedCallback: (() -> Void)?
    
    var isLoggedIn = false
    override func viewDidLoad() {
        super.viewDidLoad()
        activityIndicator.isHidden = true
        loginButton.readPermissions = ["public_profile","email", "user_friends"]
        loginButton.delegate = self
        
        
    }
    
    func fetchFacebookUserForID(ID: String) {
        let params = ["fields": "email, first_name, last_name, picture.type(large)"]
        FBSDKGraphRequest(graphPath: "me", parameters: params).start { [unowned self](connection, result, error) in
            if error != nil {
                print(error!)
                self.showMessageToUser()
                return
            }
            
            var user = [String: Any]()
            guard let data = result as? NSDictionary else { return }
            
            user["id"] = ID
            
            if let firstName = data["first_name"] as? String {
                user["firstName"] = firstName
            }
            if let lastName = data["last_name"] as? String {
                user["lastName"] = lastName
            }
            if let email = data["email"] as? String {
                user["email"] = email
            }
            if let phone = data["phoneNumber"] as? String {
                user["phone"] = phone
            }
            
            if let picture = data["picture"] as? NSDictionary,
                let data = picture["data"] as? NSDictionary,
                let url = data["url"] as? String {
                user["picture"] = url
            }
            /*
            guard let completionAuthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompletionAuth") as? CompletionAuthViewController else { return }
            completionAuthVC.userDict = user
            completionAuthVC.successCallback = self.successCallback
            completionAuthVC.failedCallback = self.failedCallback
            
            self.present(completionAuthVC, animated: true, completion: nil)*/
            
            UsersManager.defaultManager.getUser(withId: ID, handler: {[unowned self] (gotUser) in
                if gotUser != nil {
                    self.view.window!.rootViewController?.dismiss(animated: false, completion: nil)
                    UsersManager.defaultManager.currentUser = gotUser
                    DispatchQueue.main.asyncAfter(deadline: .now()+2) {
                        if let success = self.successCallback {
                            success()
                        }
                    }
                } else {
                    guard let completionAuthVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "CompletionAuth") as? CompletionAuthViewController else { return }
                    completionAuthVC.userDict = user
                    completionAuthVC.successCallback = self.successCallback
                    completionAuthVC.failedCallback = self.failedCallback
                    
                    
                    self.present(completionAuthVC, animated: true, completion: nil)
                }
            })
            
        }
        
    }
    
    func showMessageToUser() {
        let alert = UIAlertController(title:"Авторизация" , message: "Не удалось авторизироваться с пoмощью Facebook", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    func showLoadingState() {
        messageForUser.isHidden = true
        activityIndicator.startAnimating()
        activityIndicator.isHidden = false
        loginButton.isHidden = true
        cancelButton.isHidden = true
    }
    
    func showContent() {
        messageForUser.isHidden = false
        activityIndicator.stopAnimating()
        activityIndicator.isHidden = true
        loginButton.isHidden = false
        cancelButton.isHidden = false 
    }
    
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        
        showLoadingState()
        
        if error != nil || FBSDKAccessToken.current() == nil {
            if error != nil {
                print(error!)
            }
            self.showMessageToUser()
            showContent()
            return
        }
        
        let credential = FIRFacebookAuthProvider.credential(withAccessToken: FBSDKAccessToken.current().tokenString)
        FIRAuth.auth()?.signIn(with: credential) {[unowned self] (user, error) in
            if error != nil {
                print(error!)
                self.showMessageToUser()
                self.showContent()
                return
            }
            if let user = user {
                self.fetchFacebookUserForID(ID: user.uid)
            }
        }
    }
    
    
    @IBAction func cancelButtonWasTouched() {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    
    public func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        UsersManager.defaultManager.logOut()
    }
    


}
































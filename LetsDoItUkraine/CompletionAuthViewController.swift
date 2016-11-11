//
//  CompletionAuthViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 04.11.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class CompletionAuthViewController: UIViewController {

    
    @IBOutlet weak var userFirstName: UITextField!
    @IBOutlet weak var userLastName: UITextField!
    @IBOutlet weak var userMail: UITextField!
    @IBOutlet weak var userPhoneNumber: UITextField!
    @IBOutlet weak var userCity: UITextField!
    
    var successCallback: (() -> Void)?
    var failedCallback: (() -> Void)?
    
    var userDict = [String: Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        userFirstName.text = userDict["firstName"] as? String
        userLastName.text = userDict["lastName"] as? String
        userMail.text = userDict["email"] as? String
        userCity.text = userDict["city"] as? String
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func DoneButtonWasTouched() {
        var user = User()
        guard let ID = userDict["id"] as? String, let firstName = userFirstName.text else {return}
        user.ID = ID
        user.firstName = firstName
        user.firstName = firstName
        user.lastName = userLastName.text
        user.city = userCity.text
        user.email = userMail.text
        user.phone = userPhoneNumber.text
        if let photo = userDict["picture"] as? String {
            user.photo = URL(string: photo)
        }
        
        UsersManager.defaultManager.createUser(user) { [unowned self] (error, user) in
            if error != nil {
                if let failed = self.failedCallback {
                    failed()
                }
            } else {
                UsersManager.defaultManager.currentUser = user
                if let success = self.successCallback {
                    success()
                }
            }
        }
    }
    
    
    
    
    
    
    


}

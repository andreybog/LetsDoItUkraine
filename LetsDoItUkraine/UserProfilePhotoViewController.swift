//
//  UserProfilePhotoViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 13.11.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class UserProfilePhotoViewController: UIViewController {

    @IBOutlet weak var userPhoto: UIImageView!
    var image = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    self.navigationItem.setHidesBackButton(false, animated: false)
    self.navigationItem.backBarButtonItem = UIBarButtonItem()
    userPhoto.image = image
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

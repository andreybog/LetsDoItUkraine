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
    self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    self.userPhoto.image = image
    self.showAnimate()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closePhoto(_ sender: AnyObject) {
        self.view.removeFromSuperview()
        self.removeAnimate()
    }
    
    func showAnimate() {
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    func removeAnimate() {
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished : Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }

}

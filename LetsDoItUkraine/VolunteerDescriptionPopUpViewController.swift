//
//  VolunteerDescriptionPopUpViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 15.11.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class VolunteerDescriptionPopUpViewController: UIViewController {
    @IBOutlet weak var volunteerPhotoImageView: UIImageView!
    @IBOutlet weak var phoneNumber: UILabel!
    @IBOutlet weak var volunteerNameLabel: UILabel!
    

    var volunteerName = String()
    var volunteerPhoneNumber = String()
    var volunteerPhoto = UIImage()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        volunteerPhotoImageView.image = volunteerPhoto
        volunteerNameLabel.text = volunteerName
        phoneNumber.text = volunteerPhoneNumber
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        self.showAnimate()
    }

    func showAnimate() {
        navigationController?.setNavigationBarHidden(true, animated: true)
        tabBarController?.tabBar.isHidden = true
        self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
        self.view.alpha = 0.0
        UIView.animate(withDuration: 0.25) {
            self.view.alpha = 1.0
            self.view.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        }
    }
    
    func removeAnimate() {
               navigationController?.setNavigationBarHidden(false, animated: true)
        tabBarController?.tabBar.isHidden = false
        UIView.animate(withDuration: 0.25, animations: {
            self.view.transform = CGAffineTransform(scaleX: 1.3, y: 1.3)
            self.view.alpha = 0.0
        }) { (finished : Bool) in
            if (finished) {
                self.view.removeFromSuperview()
            }
        }
    }

    @IBAction func phoneDidTapped(_ sender: UIButton) {
        if let url = URL(string: "tel://\(volunteerPhoneNumber)"), UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)

    }
    }

    @IBAction func closeButtonTapped(_ sender: UIButton) {
        removeAnimate()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    

   
}

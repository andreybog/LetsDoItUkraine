//
//  CleanPlaceViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 07.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher

extension Date {
    func dateStringWithFormat(format: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self as Date)
    }
}


class CleanPlaceViewController: UIViewController {
    
    
    @IBOutlet var cleaningPlaces: [UIImageView]!
    @IBOutlet weak var cleaningCoordinatorPhoto: UIImageView!
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var cleaningName: UILabel!
    @IBOutlet weak var cleaningEmail: UITextView!
    @IBOutlet weak var cleaningPhone: UITextView!
    @IBOutlet weak var cleaningDate: UILabel!
    @IBOutlet weak var cleaningPlace: UILabel!
    @IBOutlet weak var cleaningDescription: UILabel!
    @IBOutlet weak var cleaningNameCoordinator: UILabel!
    var cleaning: Cleaning!
    var coordiantors: [User]!
//    var members: [User]!


    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        let image = UIImage(named: "navBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // getCleaningMembers
        if let user = coordiantors.first {
            
            guard let cleaningPhone = user.phone else {
                return self.cleaningPhone.text = ""
            }
                self.cleaningPhone.text = cleaningPhone
            
            guard let cleaningEmail = user.email else {
                return self.cleaningEmail.text = ""
            }
                self.cleaningEmail.text = cleaningEmail
        
            guard let cleaningLastNameCoordinator = user.lastName else {
                return self.cleaningNameCoordinator.text = user.firstName
            }
            self.cleaningNameCoordinator.text = user.firstName + " " + cleaningLastNameCoordinator
            
            if let _ = user.photo {
                self.cleaningCoordinatorPhoto.kf.setImage(with: (user.photo)!)
            }
        }
        
        // getCleaning
        if let cleaning = self.cleaning {
            
            guard let _ = cleaning.datetime else {
                return self.cleaningDate.text = ""
            }
            self.cleaningDate.text = cleaning.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")
            
            self.cleaningPlace.text = cleaning.address
            
            guard let summary = cleaning.summary else {
                return self.cleaningDescription.text = ""
            }
                self.cleaningDescription.text = summary
            
            self.cleaningName.text = cleaning.address
            
            if cleaning.pictures != nil {
                for i in 0..<cleaning.pictures!.count {
                    self.cleaningPlaces[i].kf.setImage(with: cleaning.pictures?[i])
                }
            }
        }
        
        //get number of members
        self.numberOfMembers.text = cleaning.cleanersId != nil ? String(cleaning.cleanersId!.count) : "0"
        
    }

    
    @IBAction func goToWebSite(_ sender: AnyObject) {
        
        let url = URL(string: "http://www.letsdoit.ua")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func shareDialog(_ sender: AnyObject) {
         let objectsToShare = ["", UIActivityType.mail, UIActivityType.postToTwitter, UIActivityType.postToFacebook] as [Any]
        let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
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

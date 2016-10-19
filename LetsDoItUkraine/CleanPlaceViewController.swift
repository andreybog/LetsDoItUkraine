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

    @IBOutlet weak var cleaningPlacePhoto3: UIImageView!
    @IBOutlet weak var cleaningPlacePhoto2: UIImageView!
    @IBOutlet weak var cleaningPlacePhoto1: UIImageView!
    @IBOutlet weak var cleaningCoordinatorPhoto: UIImageView!
    @IBOutlet weak var numberOfMembers: UILabel!
    @IBOutlet weak var cleaningName: UILabel!
    @IBOutlet weak var cleaningEmail: UITextView!
    @IBOutlet weak var cleaningPhone: UITextView!
    @IBOutlet weak var cleaningDate: UILabel!
    @IBOutlet weak var cleaningPlace: UILabel!
    @IBOutlet weak var cleaningDescription: UILabel!
    @IBOutlet weak var cleaningNameCoordinator: UILabel!
    var cleaningID : String = "1"


    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let image = UIImage(named: "navBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        
// getCleaning
        CleaningsManager.defaultManager.getCleaning(withId: cleaningID) { [unowned self] (cleaning) in
            if let _ = cleaning {
              if let _ = cleaning?.datetime {
               self.cleaningDate.text = cleaning!.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")
              } else {
                self.cleaningDate.text = ""
                }
                
                self.cleaningPlace.text = cleaning?.address
                
                if let summary = cleaning?.summary {
                   self.cleaningDescription.text = summary
                } else {
                   self.cleaningDescription.text = ""
                }
                
              self.cleaningName.text = cleaning?.address
                
              if let _ = cleaning?.pictures {
               if (cleaning?.pictures?.count)! > 0 {
                 var iterator = 1
                 for item in (cleaning?.pictures)! {
                    if iterator == 1 {
                    self.cleaningPlacePhoto1.kf.setImage(with: item)
                    } else if (iterator == 2) {
                           self.cleaningPlacePhoto2.kf.setImage(with: item)
                        } else {
                            self.cleaningPlacePhoto3.kf.setImage(with: item)
                        }
                  iterator += 1
                  }
                }
              }
           }
        }
      
// getCleaningMembers
       CleaningsManager.defaultManager.getCleaningMembers(cleaningId: cleaningID, filter: .coordinator) { [unowned self](users) in
        if users.count > 0 {
            var user = User()
            user = users.first!
            if let cleaningPhone = user.phone {
                self.cleaningPhone.text = cleaningPhone
            } else {
                self.cleaningPhone.text = ""
            }
            
            if let cleaningEmail = user.email {
                self.cleaningEmail.text = cleaningEmail
            } else {
                self.cleaningEmail.text = ""
            }
            
            if let cleaningLastNameCoordinator = user.lastName {
                self.cleaningNameCoordinator.text = user.firstName + " " + cleaningLastNameCoordinator
            } else {
                self.cleaningNameCoordinator.text = user.firstName
            }
            
            if let _ = user.photo {
              self.cleaningCoordinatorPhoto.kf.setImage(with: (user.photo)!)
            }
            
          }
        }
        
//  count cleaning members
        CleaningsManager.defaultManager.getCleaningMembers(cleaningId: cleaningID, filter: .cleaner) { [unowned self](users) in
          if users.count > 0 {
             self.numberOfMembers.text = String(users.count)
            }
        }
    

        
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

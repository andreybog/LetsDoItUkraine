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
        let image = UIImage(named: "NavigationBarBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]

        
// getCleaning
        CleaningsManager.defaultManager.getCleaning(withId: cleaningID) { [unowned self] (cleaning) in
            if cleaning != nil {
              self.cleaningDate.text = cleaning?.datetime != nil ? cleaning!.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ") : ""
              self.cleaningPlace.text = cleaning?.address != nil ? cleaning!.address : ""
              self.cleaningDescription.text = cleaning?.summary != nil ? cleaning!.summary : ""
              self.cleaningName.text = cleaning?.address != nil ? cleaning!.address : ""
                
              if (cleaning?.pictures?.count)! > 0 {
                let cleaningPlace = ImageResource(downloadURL: (cleaning?.pictures?[0])! as URL, cacheKey: "")
                self.cleaningPlacePhoto1.kf.setImage(with: cleaningPlace)
                }
                
                
            //if (cleaning?.pictures?.count)! > 0 {
                //for item in (cleaning?.pictures)! {
                 // self.cleaningPlacePhoto1.image = UIImage(data: try! NSData(contentsOf: item) as Data)
               // }
            //}
            }
        }
      
// getCleaningMembers
       CleaningsManager.defaultManager.getCleaningMembers(cleaningId: cleaningID, filter: .coordinator) { [unowned self](users) in
        if users.count > 0 {
          self.cleaningPhone.text = users[0].phone != nil ? users[0].phone : ""
          self.cleaningEmail.text = users[0].email != nil ? users[0].email : ""
          self.cleaningNameCoordinator.text = users[0].firstName + " " + users[0].lastName!
          let photoCoordinator = ImageResource(downloadURL: (users[0].photo)! as URL, cacheKey: "")
          self.cleaningCoordinatorPhoto.kf.setImage(with: photoCoordinator)

            
            
          
            
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

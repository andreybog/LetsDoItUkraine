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
    
    @IBOutlet weak var goToCleaning: UIButton!
    
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
    var firstNameMember:[String] = ["Ivan", "Stephan", "Mike"]
    var lastNameMember:[String] = ["Qqqqq", "Ddddd", "Xxxx"]
    var phoneMember:[String] = ["11111", "22222", "33333"]
    var photoMember:URL = NSURL(string: "") as! URL
////   var members: [User]!


    
    override func viewDidLoad() {
        
        super.viewDidLoad()
                
        let image = UIImage(named: "navBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        // getCleaningMembers
        if let user = coordiantors.first {

            self.cleaningPhone.text = user.phone ?? ""
            self.cleaningEmail.text = user.email ?? ""
            self.cleaningNameCoordinator.text = user.firstName + " " + (user.lastName ?? "")
            
            if let _ = user.photo {
                self.cleaningCoordinatorPhoto.kf.setImage(with: (user.photo)!)
            }
        }
        
        // getCleaning
        if let cleaning = self.cleaning {
            
            self.cleaningPlace.text = cleaning.address
            self.cleaningName.text = cleaning.address
            self.cleaningDescription.text = cleaning.summary ?? ""

            
            if cleaning.pictures != nil {
                for i in 0..<cleaning.pictures!.count {
                    self.cleaningPlaces[i].kf.setImage(with: cleaning.pictures?[i])
                }
            }
            
            self.numberOfMembers.text = String(cleaning.cleanersIds!.count)
            
            for id in self.cleaning.cleanersIds! {
               UsersManager.defaultManager.getUser(withId: id, handler: { (mem) in
                   print(mem?.firstName)
                })
           }
            
            guard let _ = cleaning.datetime else {
              self.cleaningDate.text = ""
                return
            }
            self.cleaningDate.text = cleaning.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")

            
                 } else {
            self.numberOfMembers.text = "0"
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let listMembersVC = segue.destination as! ListOfMembers
//         if let cleaning = self.cleaning {
        //            for id in self.cleaning.cleanersIds! {
        //                UsersManager.defaultManager.getUser(withId: "i36", handler: { (mem) in
        //                    print(mem?.firstName)
        //                })
        //            }
//          }
    
        listMembersVC.firstNameMember = self.firstNameMember
        listMembersVC.lastNameMember = self.lastNameMember
        listMembersVC.phoneMember = self.phoneMember
        listMembersVC.photoMember = self.photoMember
        
    }
    

     @IBAction func goToCleaning(_ sender: AnyObject) {

        //CleaningsManager.defaultManager.addMember(<#T##user: User##User#>, toCleaning: self.cleaning, as: .cleaner)
        self.goToCleaning.isEnabled = false
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

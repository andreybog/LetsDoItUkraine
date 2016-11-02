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
    
    @IBOutlet weak var volunteers: UILabel!
    @IBOutlet weak var coordinators: UILabel!
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
    var firstNameMember = [String]()
    var lastNameMember = [String]()
    var phoneMember = [String]()
    var photoMember = [URL]()
    var idUser:[String] = [""]
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
            
            self.cleaningPhone.text = user.phone ?? "Не укзаан"
            self.cleaningEmail.text = user.email ?? "Не указан"
            self.cleaningNameCoordinator.text = user.firstName + " " + (user.lastName ?? "")
            
            if let photo = user.photo {
                self.cleaningCoordinatorPhoto.kf.setImage(with: photo, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
        }
        
        // getCleaning
        if let cleaning = self.cleaning {
            
            self.cleaningPlace.text = cleaning.address
            self.cleaningName.text = cleaning.address
            self.cleaningDescription.text = cleaning.summary ?? ""
            
            
            if cleaning.pictures != nil {
                let minValue = min(self.cleaningPlaces.count, cleaning.pictures!.count)
                for i in 0..<minValue {
                    self.cleaningPlaces[i].kf.setImage(with: cleaning.pictures?[i], placeholder: #imageLiteral(resourceName: "placeholder"))
                }
            }
            
            self.numberOfMembers.text = String(cleaning.cleanersIds!.count)
            self.coordinators.text = String(cleaning.coordinatorsIds!.count)
            self.volunteers.text = String(cleaning.cleanersIds!.count)
            
            if let _ = cleaning.datetime {
                self.cleaningDate.text = cleaning.datetime!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")
            } else {
                self.cleaningDate.text = ""
            }
            
            
        } else {
            self.numberOfMembers.text = "0"
            self.coordinators.text = "0"
            self.volunteers.text = "0"
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
    
    @IBAction func openListOfMembers(_ sender: AnyObject) {
        //For test
        self.performSegue(withIdentifier: "toListMembers", sender: self)
        
        //Not for test
        /*
        UsersManager.defaultManager.getCurrentUser { (cUsers) in
            if let user = cUsers, let coordinatorIds = user.asCoordinatorIds, coordinatorIds.contains(self.cleaning.ID) {
                self.performSegue(withIdentifier: "toListMembers", sender: self)
            }
        }
        */

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //REMOVE
        if segue.identifier == "toListMembers" {
            let listMembersVC = segue.destination as! ListOfMembers
            firstNameMember = []
            lastNameMember = []
            phoneMember = []
            photoMember = []
            if let _ = self.cleaning {
                for idd in self.cleaning.cleanersIds! {
                    UsersManager.defaultManager.getUser(withId: idd, handler: { (mem) in

                        if mem != nil {
                            let firstN = mem?.firstName ?? ""
                            let lastN = mem?.lastName ?? ""
                            let phoneN = mem?.phone ?? ""
                            
                            self.idUser.append((mem?.ID)!)
                            self.firstNameMember.append(firstN)
                            self.phoneMember.append(phoneN)
                            self.lastNameMember.append(lastN)
                            self.photoMember.append((mem?.photo)! as URL)
                        }
                    })
                }
            }
            
            listMembersVC.firstNameMember = self.firstNameMember
            listMembersVC.lastNameMember = self.lastNameMember
            listMembersVC.phoneMember = self.phoneMember
            listMembersVC.photoMember = self.photoMember
            listMembersVC.idUser = self.idUser
        }
        
    }
    
    
    @IBAction func goToCleaning(_ sender: AnyObject) {
        
        //UsersManager.defaultManager.getCurrentUser { (cUsers) in
        //    print(cUsers)
        //}
        
        // no need
        var curUser = User()
        curUser.ID = "i25"
        curUser.firstName = "Анна"
        curUser.lastName = "Фугас"
        curUser.asCleanerIds = ["i08"]
        // let curUser: User? = nil
        //
        
        if curUser != nil {
            CleaningsManager.defaultManager.addMember(curUser, toCleaning: self.cleaning, as: .cleaner)
            self.goToCleaning.isEnabled = false
            self.goToCleaning.setTitleColor(UIColor.gray, for: UIControlState.normal)
        } else {
            print("need registration")
            self.performSegue(withIdentifier: "authorizationMember", sender: self)
        }
        
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

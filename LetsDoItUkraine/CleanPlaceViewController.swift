//
//  CleanPlaceViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 07.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher
import Firebase

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
    
    @IBOutlet weak var listOfMembers: UIButton!
    @IBOutlet weak var volunteers: UILabel!
    @IBOutlet weak var coordinatorsLabel: UILabel!
    //@IBOutlet var cleaningPlaces: [UIImageView]!
    @IBOutlet var cleaningPlacesButtons: [UIButton]!
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
    var coordiantors: [User]?
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
            
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
    
        let updateCoordinators = { [unowned self] in
            let user = self.coordiantors!.first!
            
            self.cleaningPhone.text = user.phone ?? "Не укзаан"
            self.cleaningEmail.text = user.email ?? "Не указан"
            self.cleaningNameCoordinator.text = user.firstName + " " + (user.lastName ?? "")
            
            if let photo = user.photo {
                self.cleaningCoordinatorPhoto.kf.setImage(with: photo, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
        }
        
        // getCleaningMembers
        if let _ = coordiantors {
            updateCoordinators()
            
        } else {
            UsersManager.defaultManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { (users) in
                if !users.isEmpty {
                    self.coordiantors = users
                    updateCoordinators()
                }
            })
        }
        
        
        // getCleaning
        if let cleaning = self.cleaning {
            
            self.cleaningPlace.text = cleaning.address
            self.cleaningName.text = cleaning.address
            self.cleaningDescription.text = cleaning.summary ?? ""
            
            
            if cleaning.pictures != nil {
                let minValue = min(self.cleaningPlacesButtons.count, cleaning.pictures!.count)
                for i in 0..<minValue {
                   let data = NSData(contentsOf:(cleaning.pictures?[i])!)
                    if data != nil {
                    self.cleaningPlacesButtons[i].setImage(UIImage(data:data! as Data), for: .normal)
                        //setBackgroundImage(UIImage(data:data! as Data), for: .normal)
                    //self.cleaningPlaces[i].kf.setImage(with: cleaning.pictures?[i], placeholder: #imageLiteral(resourceName: "placeholder"))
                    }
                }
            }
            
            self.numberOfMembers.text = String(cleaning.cleanersIds?.count ?? 0)
            self.coordinatorsLabel.text = String(cleaning.coordinatorsIds!.count)
            self.volunteers.text = String(cleaning.cleanersIds?.count ?? 0)
            
            if let _ = cleaning.datetime {
                self.cleaningDate.text = cleaning.startAt!.dateStringWithFormat(format: "dd MMMM yyyy, hh:mm ")
            } else {
                self.cleaningDate.text = "Не указано"
            }
            
            
        } else {
            self.numberOfMembers.text = "0"
            self.coordinatorsLabel.text = "0"
            self.volunteers.text = "0"
        }
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateUIWith(user: UsersManager.defaultManager.currentUser)
    }
    
    func updateUIWith(user: User?) {
        
        if let currentUser = user {
            self.listOfMembers.isHidden = !self.cleaning.coordinatorsIds!.contains(currentUser.ID)
            
            goToCleaning.isEnabled = UsersManager.defaultManager.isCurrentUserCanAddCleaning
     
        } else {
            self.listOfMembers.isHidden = true
            goToCleaning.isEnabled = true
        }
        
        goToCleaning.backgroundColor = goToCleaning.isEnabled ? UIColor.dirtyGreen() : UIColor.gray
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
        //self.performSegue(withIdentifier: "toListMembers", sender: self)
        UsersManager.defaultManager.getCurrentUser { [unowned self] (cUsers) in
            if let user = cUsers,
            let coordinatorIds = user.asCoordinatorIds,
            coordinatorIds.contains(self.cleaning.ID) {
               self.performSegue(withIdentifier: "toListMembers", sender: self)
            }
        }
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toListMembers" {
            let listMembersVC = segue.destination as! ListOfMembers
            listMembersVC.cleaning = cleaning
        }
        
    }
    
    
    @IBAction func goToCleaning(_ sender: AnyObject) {
        AuthorizationUtils.authorize(vc: self, onSuccess: { [unowned self] in
            
            DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                let currentUser = UsersManager.defaultManager.currentUser!
                
                if UsersManager.defaultManager.isCurrentUserCanAddCleaning {
                    currentUser.go(to: self.cleaning)
                    self.goToApplicationAcceptedView()
                } else {
                    self.showMessageToUser("Вы не можете иметь несколько активных уборок.")
                }
                
                }
            }, onFailed: {
                self.showMessageToUser("Авторизация не совершена. У вас ограничен доступ к этому функционалу")
                
        })
        
    }
    
    func goToApplicationAcceptedView() {
        self.performSegue(withIdentifier: "showApplicationAcceptedScreen", sender: self)
    }
    
    func showMessageToUser(_ message: String) {
        let alert = UIAlertController(title:"Авторизация" , message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    @IBAction func cancelToCleanPlaceVC(segue: UIStoryboardSegue) {
        

    }
    
    
    @IBAction func showPopUp(_ sender: UIButton) {
        //AnyObject
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "cleaningPlacePoUpID") as! PopUpViewController
        popOverVC.imageCleaningPlace = sender.imageView?.image
        
        self.addChildViewController(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParentViewController: self)
        
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

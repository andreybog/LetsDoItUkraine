//
//  userProfileViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 04.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Firebase


class UserProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var cleaningsTableView: UITableView!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var userLocationTextLabel: UILabel!
    @IBOutlet weak var coordinatorCounterTextLabel: UILabel!
    @IBOutlet weak var activityCounterTextLabel: UILabel!
    @IBOutlet weak var volunteerCounterTextLabel: UILabel!
    
    let kNoCleaningCellIdetefier = "noCleaningCell"
    let kCleaningCellIdentifier = "cleningCell"
    let kHistoryCleaningIdentifier = "HistoryCleaning"
    let kCleaningPlaceSegue = "cleaningPlaceSegue"
    let kAddCleaningSegue = "addCleaningSegue"
    let kSearchCleaningSegue = "searchCleaningSegue"
    let userID = "i01"
    var user = User()
    var userCleaningsAsModerator = [Cleaning]()
    var userCleaningsAsCleaner = [Cleaning]()
    var userCleaningsPast = [Cleaning]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.cleaningsTableView.estimatedRowHeight = 44
//        self.cleaningsTableView.rowHeight = UITableViewAutomaticDimension
//        
//        UsersManager.defaultManager.getCurrentUser { [unowned self] (user) in
//            if let currentUser = user {
//                self.user = currentUser
//                self.updateUserInformation()
//            } else {
//                let alertController = UIAlertController(title: "Unable to get user", message: "User is not found", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okAction)
//                
//                self.present(alertController, animated: true, completion: nil)
//            }
//        }
        
//        UsersManager.defaultManager.getUser(withId: userID) { [unowned self] (user) in
//            if let currentUser = user {
//                self.user = currentUser
//                self.updateUserInformation()
//            } else {
//                let alertController = UIAlertController(title: "Unable to get user", message: "User is not found", preferredStyle: .alert)
//                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
//                alertController.addAction(okAction)
//            }
//        }
//        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.cleaningsTableView.estimatedRowHeight = 44
        self.cleaningsTableView.rowHeight = UITableViewAutomaticDimension
        
        UsersManager.defaultManager.getCurrentUser { [unowned self] (user) in
            if let currentUser = user {
                self.user = currentUser
                self.updateUserInformation()
            } else {
                let alertController = UIAlertController(title: "Unable to get user", message: "User is not found", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
                
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    func updateUserInformation() {
        let lastName = self.user.lastName ?? ""
        let userCountry = self.user.country ?? ""
        let userCity = self.user.city ?? ""
        let asVolunteerIDsCounter = self.user.asCleanerIds?.count ?? 0
        let asCoordinatorIDsCounter = self.user.asCoordinatorIds?.count ?? 0
        self.userNameTextLabel.text = self.user.firstName + " " + lastName
        self.userLocationTextLabel.text = userCountry + " " + userCity
        self.coordinatorCounterTextLabel.text = String(asCoordinatorIDsCounter)
        self.volunteerCounterTextLabel.text = String(asVolunteerIDsCounter)
        if let userPhoto = self.user.photo {
            self.userPhotoImageView.kf.setImage(with: userPhoto)
            self.userPhotoImageView.contentMode = UIViewContentMode.scaleAspectFit
        } else {
            self.userPhotoImageView.image = #imageLiteral(resourceName: "placeholderUser")
        }
        if asVolunteerIDsCounter > 0 {
            CleaningsManager.defaultManager.getCleanings(withIds: user.asCleanerIds!, handler: { [unowned self] (cleanings) in
                self.userCleaningsAsCleaner = cleanings
                self.cleaningsTableView.reloadData()
            })
        } else if asCoordinatorIDsCounter > 0 {
            CleaningsManager.defaultManager.getCleanings(withIds: user.asCoordinatorIds!, handler: { [unowned self] (cleaning) in
                self.userCleaningsAsModerator = cleaning
                self.cleaningsTableView.reloadData()
            })
        }
        
        if let pastCleaningsIDs = user.pastCleaningsIds {
            CleaningsManager.defaultManager.getCleanings(withIds: pastCleaningsIDs, handler: { [unowned self] (cleanings) in
                self.userCleaningsPast = cleanings
                self.cleaningsTableView.reloadData()
            })
        }
    }
    

    

    // MARK: -UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2;
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        if section == 0 {
            return "Мои текущие уборки"
        } else {
            return "История уборок"
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            return 1
        } else {
            return userCleaningsPast.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            if (!userCleaningsAsCleaner.isEmpty || !userCleaningsAsModerator.isEmpty) {
                if let cell = tableView.dequeueReusableCell(withIdentifier:  kCleaningCellIdentifier, for: indexPath) as? CleaningCell {
                    var cleaning: Cleaning
                    if !userCleaningsAsModerator.isEmpty {
                        cleaning = userCleaningsAsModerator[indexPath.row]
                    } else {
                        cleaning = userCleaningsAsCleaner[indexPath.row]
                    }
                    cell.configureWithCleaning(cleaning:cleaning)
                    return cell
                }
                return UITableViewCell()
            } else {
                if let cell: UITableViewCell = tableView.dequeueReusableCell(withIdentifier:kNoCleaningCellIdetefier, for: indexPath) as? NoCleaningCell {
                    return cell
                }
                return UITableViewCell()
            }
        } else {
            if let cell = tableView.dequeueReusableCell(withIdentifier:  kCleaningCellIdentifier, for: indexPath) as? HistoryCleningCell {
                cell.configureWithCleaning(cleaning: userCleaningsPast[indexPath.row])
                return cell
            }
            return UITableViewCell()
        }
    }
    
    // MARK: -Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        switch segue.identifier! {
        case kCleaningPlaceSegue:
            let nextScene = segue.destination as? CleanPlaceViewController
            if let indexPath = cleaningsTableView.indexPathForSelectedRow {
                var cleaning: Cleaning
                if !userCleaningsAsModerator.isEmpty {
                    cleaning = userCleaningsAsModerator[indexPath.row]
                } else {
                    cleaning = userCleaningsAsCleaner[indexPath.row]
                }
                nextScene?.cleaning = cleaning
            }
        case kAddCleaningSegue:
            _ = segue.destination as? CleaningsViewController
        case kSearchCleaningSegue:
            _ = segue.destination as? CleaningsViewController
        default:
            break
        }
    }
    
    
    // MARK: -Actions

    @IBAction func searchCleaningsButtonDidTapped(_ sender: AnyObject) {
        performSegue(withIdentifier:kSearchCleaningSegue, sender: self)
    }
    
    @IBAction func addCleaningDidTapped(_ sender: AnyObject) {
        AuthorizationUtils.authorize(vc: self, onSuccess: { [unowned self] in
            self.goToCreationCleaningVC()
            }, onFailed: {
                self.showMessageToUser()
        })
    }
    
    func goToCreationCleaningVC() {
       performSegue(withIdentifier:kAddCleaningSegue, sender: self)
    }

    @IBAction func settingsButtonDidTapped(_ sender: AnyObject) {
    }
    
    func showMessageToUser() {
        let alert = UIAlertController(title:"Авторизация" , message: "Авторизация не совершена. У вас ограничен доступ к этому функционалу", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    
}



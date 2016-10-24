//
//  userProfileViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 04.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit


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
    let userID = "1"
    var user = User()
    var userCleaningsAsModerator = [Cleaning]()
    var userCleaningsAsCleaner = [Cleaning]()
    var userCleaningsPast = [Cleaning]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.cleaningsTableView.estimatedRowHeight = 44
        self.cleaningsTableView.rowHeight = UITableViewAutomaticDimension
        
        UsersManager.defaultManager.getUser(withId: userID) { [unowned self] (user) in
            if let currentUser = user {
                self.user = currentUser
                self.updateUserInformationUI()
            } else {
                let alertController = UIAlertController(title: "Unable to get user", message: "User is not found", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(okAction)
            }
        }
        
        UsersManager.defaultManager.getUserCleanings(userId: userID, filter: .asCleaner) { [unowned self] (cleanings) in
            self.userCleaningsAsCleaner = cleanings
            self.volunteerCounterTextLabel.text = String(self.userCleaningsAsCleaner.count)
            self.cleaningsTableView.reloadData()
        }
        
        UsersManager.defaultManager.getUserCleanings(userId: userID, filter: .asModerator) { [unowned self] (cleanings) in
            self.userCleaningsAsModerator = cleanings
            self.coordinatorCounterTextLabel.text = String(self.userCleaningsAsModerator.count)
            self.cleaningsTableView.reloadData()
        }
        
        UsersManager.defaultManager.getUserCleanings(userId: userID, filter: .past) { [unowned self] (cleanings) in
            self.userCleaningsPast = cleanings
            self.cleaningsTableView.reloadData()
        }
    }

    func updateUserInformationUI() {
        if let lastName = self.user.lastName {
            self.userNameTextLabel.text = ("\(self.user.firstName) \(lastName)")
        } else {
            self.userNameTextLabel.text = ("\(self.user.firstName)")
        }
        self.userLocationTextLabel.text = ("\(self.user.country!), г.\(self.user.city!)")
    }
    
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 {
        let cleaning = userCleaningsAsCleaner.count > 0 ? userCleaningsAsCleaner[indexPath.row] : userCleaningsAsModerator[indexPath.row]
        //performSegue(withIdentifier: "cleanPlaceSegue", sender: cleaning)
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
            if (userCleaningsAsCleaner.count > 0 || userCleaningsAsModerator.count > 0) {
                if let cell = tableView.dequeueReusableCell(withIdentifier:  kCleaningCellIdentifier, for: indexPath) as? CleaningCell {
                    cell.configureWithCleaning(cleaning: userCleaningsAsCleaner.count > 0 ? userCleaningsAsCleaner[indexPath.row] : userCleaningsAsModerator[indexPath.row])
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
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        switch segue.identifier {
//        case segue.identifier == "cleanPlaceSegue":
//            let nextScene = segue.destination as? CleanPlaceViewController
//        case segue.identifier == "addCleaning":
//            let nextScene = segue.destination as? CleanPlaceViewController
//        case segue.identifier == "searchCleaning":
//            let nextScene = segue.destination as? CleaningsViewController
//        default:
//            break
//        }
//    }
    
    
    // MARK: -Actions

    @IBAction func searchCleaningsButtonDidTapped(_ sender: AnyObject) {
         print("search button tapped")
        //performSegue(withIdentifier: "searchCleaning", sender: self)
    }
    
    @IBAction func addCleaningDidTapped(_ sender: AnyObject) {
        print("add button tapped")
        //performSegue(withIdentifier: "addCleaning", sender: self)
    }

    @IBAction func settingsButtonDidTapped(_ sender: AnyObject) {
    }
    
}



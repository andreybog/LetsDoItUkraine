//
//  ListOfMembers.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 27.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher

class ListOfMembers: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet weak var tableViewMembers: UITableView!
   
    var listOfMembersCleaning = [User]()
    var cleaning: Cleaning!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        NotificationCenter.default.addObserver(self, selector: #selector(handleCleaningDidChangedNotification), name: kCleaningsManagerCleaningChangeNotification, object: nil)
        
        loadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func loadData() {
        if cleaning != nil && cleaning.cleanersIds != nil {
            let group = DispatchGroup()
            listOfMembersCleaning = []
            
            for idCleaner in self.cleaning.cleanersIds! {
                group.enter()
                UsersManager.defaultManager.getUser(withId: idCleaner, handler: { [weak self] (memberOfCleaning) in
                    if memberOfCleaning != nil {
                        self?.listOfMembersCleaning.append(memberOfCleaning!)
                    }
                    group.leave()
                })
            }
            group.notify(queue: DispatchQueue.main) {
                self.tableViewMembers.reloadData()
            }
            
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listOfMembersCleaning.count
    }
   
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = self.tableViewMembers.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellCleanMember
        
        if listOfMembersCleaning.count > indexPath.row {
            let member = listOfMembersCleaning[indexPath.row]
            
          cell.nameMember.text = "\(member.firstName) \(member.lastName ?? "")"
          cell.phoneMember.text = member.phone ?? "Не укзаан"
          cell.photoMember.kf.setImage(with: member.photo, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
        
    }

    @objc private func handleCleaningDidChangedNotification(_ notification: Notification) {
        let changedCleaning = notification.userInfo?[kCleaningsManagerCleaningKey] as! Cleaning
        
        if changedCleaning.ID == cleaning.ID {
            loadData()
        }
    }

    // MARK: -TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let currentCell = tableView.cellForRow(at:indexPath) as! CustomCellCleanMember
        let volunteerPopUpVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "volunteerDescriptionPopUp") as! VolunteerDescriptionPopUpViewController
        volunteerPopUpVC.volunteerPhoto = currentCell.photoMember.image!
        volunteerPopUpVC.volunteerName = currentCell.nameMember.text!
        volunteerPopUpVC.volunteerPhoneNumber = currentCell.phoneMember.text!
        self.addChildViewController(volunteerPopUpVC)
        volunteerPopUpVC.view.frame = self.view.frame
        self.view.addSubview(volunteerPopUpVC.view)
        volunteerPopUpVC.didMove(toParentViewController: self)
    }

}

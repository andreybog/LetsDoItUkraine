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

        if (self.cleaning != nil) && (self.cleaning.cleanersIds != nil) {
            let group = DispatchGroup()
            for idCleaner in self.cleaning.cleanersIds! {
                group.enter()
                UsersManager.defaultManager.getUser(withId: idCleaner, handler: { (memberOfCleaning) in
                    if memberOfCleaning != nil {
                        self.listOfMembersCleaning.append(memberOfCleaning!)
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
          cell.nameMember.text = listOfMembersCleaning[indexPath.row].firstName + " " + (listOfMembersCleaning[indexPath.row].lastName ?? "")
          cell.phoneMember.text = listOfMembersCleaning[indexPath.row].phone ?? "Не указан"
          cell.photoMember.kf.setImage(with: listOfMembersCleaning[indexPath.row].photo, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
        
    }
    
    // MARK: -TableViewDelegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
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

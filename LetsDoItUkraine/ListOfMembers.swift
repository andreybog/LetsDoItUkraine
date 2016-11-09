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
   
    var listUsers = [User]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listUsers.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = self.tableViewMembers.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellCleanMember
        
        if listUsers.count > indexPath.row {
          cell.nameMember.text = listUsers[indexPath.row].firstName + " " + (listUsers[indexPath.row].lastName ?? "")
          cell.phoneMember.text = listUsers[indexPath.row].phone ?? "Не укзаан"
          cell.photoMember.kf.setImage(with: listUsers[indexPath.row].photo, placeholder: #imageLiteral(resourceName: "placeholder"))
        }
        
        return cell
        
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

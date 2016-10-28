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
   
    var firstNameMember:[String] = [""]
    var lastNameMember:[String] = [""]
    var phoneMember:[String] = [""]
    var photoMember = [URL]()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.firstNameMember.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
       let cell = self.tableViewMembers.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! CustomCellCleanMember
        if firstNameMember.count > 0 {
          cell.nameMember.text = firstNameMember[indexPath.row] + " " + lastNameMember[indexPath.row]
          cell.phoneMember.text = phoneMember[indexPath.row]
          cell.photoMember.kf.setImage(with: photoMember[indexPath.row])
            
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

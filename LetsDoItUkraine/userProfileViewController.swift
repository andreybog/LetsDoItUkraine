//
//  userProfileViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 04.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit


class userProfileViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var cleaningsTableView: UITableView!
    @IBOutlet weak var userPhotoImageView: UIImageView!
    @IBOutlet weak var userNameTextLabel: UILabel!
    @IBOutlet weak var userLocationTextLabel: UILabel!
    @IBOutlet weak var coordinatorCounterTextLabel: UILabel!
    @IBOutlet weak var activityCounterTextLabel: UILabel!
    @IBOutlet weak var volunteerCounterTextLabel: UILabel!
    
    let kNoCleaningCellIdetefier = "noCleaningCell"
    let kCleaningCellIdentifier = "cleningCell"
    
    let historyCleanings = ["1", "2", "3"]
    let cleaning = ["1"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: -UITableViewDelegate

    
    
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
            return historyCleanings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cleaningCell = tableView.dequeueReusableCell(withIdentifier:  kCleaningCellIdentifier, for: indexPath) as! CleaningCell
        
        return cleaningCell
    }
    
}

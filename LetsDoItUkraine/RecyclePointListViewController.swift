//
//  RecuclePointListViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 16.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class RecyclePointListViewController: UIViewController {
    
    
    @IBOutlet weak var plasticButton: Checkbox!
    @IBOutlet weak var wastePaperButton: Checkbox!
    @IBOutlet weak var glassButton: Checkbox!
    @IBOutlet weak var mercuryButton: Checkbox!
    @IBOutlet weak var batteryButton: Checkbox!
    @IBOutlet weak var oldThingsButton: Checkbox!
    @IBOutlet weak var polytheneButton: Checkbox!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func searchButtonWasTapped(_ sender: AnyObject) {
        var categories = [RecyclePointCategory]()
        if plasticButton.isChecked {
            categories.append(.Plastic)
        }
        if wastePaperButton.isChecked {
            categories.append(.WastePaper)
        }
        if glassButton.isChecked {
            categories.append(.Glass)
        }
        if mercuryButton.isChecked {
            categories.append(.Mercury)
        }
        if batteryButton.isChecked {
            categories.append(.Battery)
        }
        if oldThingsButton.isChecked {
            categories.append(.OldThings)
        }
        if polytheneButton.isChecked {
            categories.append(.Polythene)
        }
        
        let manager = RecyclePointsManager()
        manager.getSelectedRecyclePoints(categories: categories) { (recyclePoints) in
            //
        }
        
    }
    
    
}








//
//  RecuclePointListViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 16.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class RecyclePointListViewController: UIViewController {
    
    var selectedCategories = Set<RecyclePointCategory>()
    
    
    @IBOutlet weak var plasticButton: Checkbox!
    @IBOutlet weak var wastePaperButton: Checkbox!
    @IBOutlet weak var glassButton: Checkbox!
    @IBOutlet weak var mercuryButton: Checkbox!
    @IBOutlet weak var batteryButton: Checkbox!
    @IBOutlet weak var oldThingsButton: Checkbox!
    @IBOutlet weak var polytheneButton: Checkbox!
    
    var checkboxesWithCategories = [(Checkbox, RecyclePointCategory)]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkboxesWithCategories = [(plasticButton, .Plastic), (wastePaperButton, .WastePaper),
        (glassButton, .Glass), (mercuryButton, .Mercury), (batteryButton, .Battery), (oldThingsButton, .OldThings),
        (polytheneButton, .Polythene)]
        
        for (chb, category) in checkboxesWithCategories {
            chb.isChecked = selectedCategories.contains(category)
        }
    }
    
    @IBAction func searchButtonWasTapped(_ sender: AnyObject) {
        selectedCategories = Set<RecyclePointCategory>()
        
        // pass copy set
        for (chb, category) in checkboxesWithCategories {
            if chb.isChecked {
                selectedCategories.insert(category)
            }
        }
        
        
        
        
    }
    
}








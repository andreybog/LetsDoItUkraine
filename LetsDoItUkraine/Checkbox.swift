//
//  Checkbox.swift
//  LetsDoItUkraine
//
//  Created by user on 18.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class Checkbox: UIButton {
    
    var checkedImage = UIImage(named: "GlassRecyclePoint")
    let uncheckedImage = UIImage(named: "DefaultRecyclePoint")
    
    func checkImage() {
        if self.accessibilityIdentifier == "Plastic" {
            checkedImage = UIImage(named: "PlasticRecyclePoint")
        } else if self.accessibilityIdentifier == "WastePaper" {
            checkedImage = UIImage(named: "WastePaperRecyclePoint")
        } else if self.accessibilityIdentifier == "Glass" {
            checkedImage = UIImage(named: "GlassRecyclePoint")
        } else if self.accessibilityIdentifier == "Mercury" {
            checkedImage = UIImage(named: "MercuryRecyclePoint")
        } else if self.accessibilityIdentifier == "Battery" {
            checkedImage = UIImage(named: "BatteryRecyclePoint")
        } else if self.accessibilityIdentifier == "OldThings" {
            checkedImage = UIImage(named: "OldThingsRecyclePoint")
        } else if self.accessibilityIdentifier == "Polythene" {
            checkedImage = UIImage(named: "PolytheneRecyclePoint")
        } else if self.accessibilityIdentifier == "Different" {
            checkedImage = UIImage(named: "DifferentRecyclePoint")
        } else if self.accessibilityIdentifier == "All" {
            checkedImage = UIImage(named: "AllRecyclePoints")
        }
    }

    
    
    var isChecked: Bool = false {
        didSet {
            if isChecked == true {
                self.setBackgroundImage(checkedImage, for: .normal)
            } else {
                self.setBackgroundImage(uncheckedImage, for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        checkImage()
        self.addTarget(self, action: #selector(buttonWasClicked), for: .touchUpInside)
        isChecked = false
    }
    
    func buttonWasClicked() {
        if isChecked {
            isChecked = false
        } else {
            isChecked = true
        }
    }
}

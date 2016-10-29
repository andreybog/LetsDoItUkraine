//
//  Checkbox.swift
//  LetsDoItUkraine
//
//  Created by user on 18.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class Checkbox: UIButton {
    
    @IBInspectable var checkedImgName: String?
    @IBInspectable var uncheckedImgName: String?
    
    @IBInspectable var isChecked: Bool = false {
        didSet {
            if let imageName = isChecked ? checkedImgName : uncheckedImgName {
                self.setBackgroundImage(UIImage(named: imageName), for: .normal)
            }
        }
    }
    
    override func awakeFromNib() {
        self.addTarget(self, action: #selector(buttonWasClicked), for: .touchUpInside)
        isChecked = false
    }
    
    func buttonWasClicked() {
        isChecked = !isChecked
    }
}

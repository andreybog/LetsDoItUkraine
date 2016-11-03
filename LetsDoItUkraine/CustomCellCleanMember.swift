//
//  CustomCellCleanMember.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 27.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class CustomCellCleanMember: UITableViewCell {

    @IBOutlet weak var phoneMember: UITextView!
    @IBOutlet weak var logoPhoneMember: UIImageView!
    @IBOutlet weak var nameMember: UILabel!
    @IBOutlet weak var photoMember: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  NoCleaningCell.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 10.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class NoCleaningCell: UITableViewCell {
    @IBOutlet var addCleaningButton: UIButton!
    
    @IBOutlet var searchCleaningButton: UIButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

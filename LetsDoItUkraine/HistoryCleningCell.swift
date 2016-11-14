//
//  HistoryCleningCell.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 16.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class HistoryCleningCell: UITableViewCell {
    @IBOutlet weak var cleaningAdressTextLabel: UILabel!
    @IBOutlet var cleaningDateTextLabel: UILabel!
    
    
        override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithCleaning (cleaning:Cleaning) {
        cleaningDateTextLabel.text = cleaning.startAt.shortDate
        cleaningAdressTextLabel.text = cleaning.address
    }

}

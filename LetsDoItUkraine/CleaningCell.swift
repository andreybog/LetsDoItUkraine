//
//  CleaningCell.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 11.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit



class CleaningCell: UITableViewCell {
    @IBOutlet weak var cleaningAdressTextLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configureWithCleaning (cleaning:Cleaning)->(CleaningCell) {
        let cell = CleaningCell()
        cleaningAdressTextLabel.text = cleaning.address != nil ? ("\(cleaning.address!)") : "Адрес не найден"
        return cell;
    }
    
}

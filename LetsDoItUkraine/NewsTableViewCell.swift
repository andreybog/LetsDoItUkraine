//
//  NewsTableViewCell.swift
//  LetsDoItUkraine
//
//  Created by user on 25.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FBSDKShareKit

class NewsTableViewCell: UITableViewCell {
    
    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var newsTitle: UILabel!
    @IBOutlet weak var newsBody: UILabel!
    @IBOutlet weak var newsDate: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    
    

}

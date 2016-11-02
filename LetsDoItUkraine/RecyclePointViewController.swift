//
//  RecyclePointViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 17.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher

class RecyclePointViewController: UIViewController {
    
    @IBOutlet weak var recyclePointData: UILabel!
    @IBOutlet weak var recyclePointCategories: UILabel!
    @IBOutlet weak var recyclePointPicture: UIImageView!
    @IBOutlet weak var recyclePointLogo: UIImageView!
    @IBOutlet weak var recyclePointAddress: UILabel!
    @IBOutlet weak var recyclePointSummary: UILabel!
    @IBOutlet weak var recyclePointSchedule: UILabel!
    @IBOutlet weak var recyclePointEmail: UILabel!

    @IBOutlet weak var recyclePointName: UILabel!
    @IBOutlet weak var recyclePointPhone: UILabel!
    var recyclePoint: RecyclePoint!
    var coordiantors: [User]!
    //    var members: [User]!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
             self.recyclePointName.text = recyclePoint?.title ?? ""
             self.recyclePointPhone.text = recyclePoint?.phone ?? ""
             self.recyclePointEmail.text = recyclePoint?.website ?? ""
             self.recyclePointSchedule.text = recyclePoint?.schedule ?? ""
             self.recyclePointAddress.text = recyclePoint?.address ?? ""
             self.recyclePointSummary.text = recyclePoint?.summary ?? ""
            
            if let _ = recyclePoint?.logo {
              self.recyclePointLogo.kf.setImage(with: recyclePoint?.logo, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
            
            if let _ = recyclePoint?.picture {
                self.recyclePointPicture.kf.setImage(with: recyclePoint?.picture, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
            //self.recyclePointData.text = recyclePoint?.
            //self.recyclePointCategories.text = recyclePoint?.categories
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}

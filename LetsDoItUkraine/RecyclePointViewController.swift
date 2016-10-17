//
//  RecyclePointViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 17.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

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
    
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()

        let image = UIImage(named: "NavigationBarBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        
            // MARK: - getRecylcePoint
        RecyclePointsManager.defaultManager.getRecylcePoint(withId: "1") { (recyclePoint) in
            self.recyclePointName.text = recyclePoint?.title
            self.recyclePointPhone.text = recyclePoint?.phone
            self.recyclePointEmail.text = recyclePoint?.website
            self.recyclePointSchedule.text = recyclePoint?.schedule
            self.recyclePointAddress.text = recyclePoint?.adress
            self.recyclePointSummary.text = recyclePoint?.summary
            
            ///
            //self.recyclePointLogo.image = recyclePoint?.logo
           // self.recyclePointPicture.image = recyclePoint?.picture
            //self.recyclePointData.text = recyclePoint?.
            //self.recyclePointCategories.text = recyclePoint?.categories
            
        }
        
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

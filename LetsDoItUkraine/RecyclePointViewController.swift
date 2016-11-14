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
   // @IBOutlet weak var recyclePointCategories: UILabel!
    
    
    @IBOutlet weak var recyclePointPicture: UIImageView!
    @IBOutlet weak var recyclePointLogo: UIImageView!
    @IBOutlet weak var recyclePointAddress: UILabel!
    @IBOutlet weak var recyclePointSummary: UILabel!
    @IBOutlet weak var recyclePointSchedule: UILabel!
    
    @IBOutlet weak var recyclePointCategories: UILabel!
    @IBOutlet weak var recyclePointEmailTextView: UITextView!
   
    @IBOutlet weak var recyclePointName: UILabel!
    
    @IBOutlet weak var recyclePointPhoneTextView: UITextView!
    var recyclePoint: RecyclePoint!
    var coordiantors: [User]!
    //    var members: [User]!
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
             self.navigationController?.navigationBar.tintColor = UIColor.white
             self.recyclePointName.text = recyclePoint?.title ?? ""
             self.recyclePointPhoneTextView.text = recyclePoint?.phone ?? "Не указан"
             self.recyclePointEmailTextView.text = recyclePoint?.website ?? "Не указан"
             self.recyclePointSchedule.text = recyclePoint?.schedule ?? "Не указан"
             self.recyclePointAddress.text = recyclePoint?.address ?? "Не указан"
             self.recyclePointSummary.text = recyclePoint?.summary ?? ""
            
            if let _ = recyclePoint?.logo {
              self.recyclePointLogo.kf.setImage(with: recyclePoint?.logo, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
        
            getStreetViewImage()
        
            if let _ = recyclePoint?.picture {
                self.recyclePointPicture.kf.setImage(with: recyclePoint?.picture, placeholder: #imageLiteral(resourceName: "placeholder"))
            }
           let stringArray = Array(recyclePoint.categories)
           var listCategory = ""
            for id in 0 ..< recyclePoint.categories.count {
              listCategory = listCategory + String(describing: stringArray[id]) + ", "
            }
        self.recyclePointCategories.text = listCategory 
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    func getStreetViewImage(){
        if let point = self.recyclePoint{
            let streetViewManager = StreetViewFormatter()
            let coordinate = "\(point.coordinate.latitude), \(point.coordinate.longitude)"
            let urlString = streetViewManager.setWideStreetViewImageWith(coordinates: coordinate)
            recyclePoint!.picture = URL(string: urlString);

        }
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

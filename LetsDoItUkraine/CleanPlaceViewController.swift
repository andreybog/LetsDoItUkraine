//
//  CleanPlaceViewController.swift
//  LetsDoItUkraine
//
//  Created by Katerina on 07.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class CleanPlaceViewController: UIViewController {

    @IBOutlet weak var cleaningEmail: UITextView!
    @IBOutlet weak var cleaningPhone: UITextView!
    @IBOutlet weak var cleaningDate: UILabel!
    @IBOutlet weak var cleaningPlace: UILabel!
    @IBOutlet weak var cleaningDescription: UILabel!
    @IBOutlet weak var cleaningNameCoordinator: UILabel!

    ////Temporary code
    var clean : [String : Any] = ["id": 1,
                                  "adress": "г. Киев, вул.Велика Василькiвська, 55",
                                  "pictures": "http://beybegi.com/pics/imgs/olympiyskiy.jpg (448KB)",
        "date": "11 ноября 2016, 12:45",
       
        "description": "НСК Олимпийский. Давайте подстрижем газон!",
        "isActive": true]
    
    ////Temporary code
    var user : [String : Any] = ["id": 1,
                                  "firstName": "Боря",
                                  "lastName": "Гордиенко",
                                  "phone": "+38093 444 09 09",
                                  "country": "Украина",
                                  "city": "Киев",
                                  "email": "gordienko.b@gmail.com",
                                  "photo": "http://beybegi.com/pics/imgs/olympiyskiy.jpg (448KB)"
                                  ]
    
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        let image = UIImage(named: "NavigationBarBackground")! as UIImage
        self.navigationController?.navigationBar.setBackgroundImage(image , for: UIBarMetrics.default)
        self.navigationItem.title = "Место уборки";
        self.navigationController!.navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.white]
        
        
        // Setup the gradient
//          let gradientLayer = CAGradientLayer()
//          gradientLayer.frame = (self.navigationController?.navigationBar.bounds)!
//          gradientLayer.colors =  [UIColor.green,UIColor.blue ].map{$0.cgColor}
//           gradientLayer.startPoint = CGPoint(x: 0.0, y: 0.5)
//           gradientLayer.endPoint = CGPoint(x: 1.0, y: 0.5)
//        
//        // Render the gradient to UIImage
//          UIGraphicsBeginImageContext(gradientLayer.bounds.size)
//          gradientLayer.render(in: UIGraphicsGetCurrentContext()!)
//          let image = UIGraphicsGetImageFromCurrentImageContext()
//          UIGraphicsEndImageContext()
//        
//        // Set the UIImage as background propert
//         self.navigationController?.navigationBar.setBackgroundImage(image, for: UIBarMetrics.default)
        
        self.cleaningDate.text = clean["date"] as! String?
        self.cleaningPlace.text = clean["adress"] as! String?
        self.cleaningDescription.text = clean["description"] as! String?
        
        self.cleaningPhone.text = user["phone"] as! String?
      //  self.cleaningPhone.textColor = UIColor.black
        self.cleaningEmail.text = user["email"] as! String?
        self.cleaningNameCoordinator.text = (user["firstName"] as! String?)! + " " + (user["lastName"] as! String?)!
        
    }

    
    @IBAction func goToWebSite(_ sender: AnyObject) {
        
        let url = URL(string: "http://www.letsdoit.ua")!
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            UIApplication.shared.openURL(url)
        }
    }
    
    @IBAction func shareDialog(_ sender: AnyObject) {
         let textToShare = "Swift is awesome!  Check out this website about it!"
         let objectsToShare = [textToShare, UIActivityType.mail, UIActivityType.postToTwitter, UIActivityType.postToFacebook] as [Any]
        let vc = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        self.present(vc, animated: true, completion: nil)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
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

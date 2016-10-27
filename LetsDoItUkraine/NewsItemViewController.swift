//
//  NewsItemViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 26.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class NewsItemViewController: UIViewController {
    
    
    @IBOutlet weak var newsItemPhoto: UIImageView!
    
    var newsItem: News?
    
    @IBOutlet weak var newsItemTitle: UILabel!
    
    @IBOutlet weak var newsItemBody: UILabel!
    
    @IBOutlet weak var NewsItemDate: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateNews()
    }

    
    func updateNews() {
        newsItemTitle.text = newsItem?.title
        newsItemBody.text = newsItem?.body
        
        if let rowDate = newsItem?.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            NewsItemDate.text = formatter.string(from: rowDate)
        }
        
        newsItemPhoto.kf.setImage(with: newsItem?.url,
                                  placeholder: UIImage(named: "placeholder"),
                                  options: nil,
                                  progressBlock: nil,
                                  completionHandler: nil)
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

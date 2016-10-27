//
//  MapsPageViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/26/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GooglePlaces

class MapsPageViewController: UIPageViewController {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    lazy var orderedViewControllers : [UIViewController] = {
        return [self.addViewControllerWith(name: "RecyclePointMap"), self.addViewControllerWith(name: "CleaningsMap")]
    }()
    
    func addViewControllerWith(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    
    @IBAction func didTouchSegmentControl(_ sender: AnyObject) {
        if let segment = sender as? UISegmentedControl{
            if segment.selectedSegmentIndex == 0{
                if let firstViewController = orderedViewControllers.first{
                    setViewControllers([firstViewController], direction: .reverse, animated: true, completion: nil)
                }
            } else {
                if let secondViewController = orderedViewControllers.last{
                    setViewControllers([secondViewController], direction: .forward, animated: true, completion: nil)
                }
            }
        }
    }
    
}

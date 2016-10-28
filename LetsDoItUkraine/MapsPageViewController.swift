//
//  MapsPageViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/26/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GooglePlaces

class MapsPageViewController: UIPageViewController, UIPageViewControllerDataSource, UISearchBarDelegate {
    
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    var recyclePointCategories = Set<RecyclePointCategory>()
    
    lazy var orderedViewControllers : [UIViewController] = {
        return [self.addViewControllerWith(name: "RecyclePointMap"), self.addViewControllerWith(name: "CleaningsMap")]
    }()
    
    func addViewControllerWith(name: String) -> UIViewController {
        return UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: name)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        
        if let firstViewController = orderedViewControllers.first{
            setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        recyclePointCategories = FiltersModel.sharedModel.categories
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    
    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let previousIndex = viewControllerIndex - 1
        
        guard previousIndex >= 0 else{
            return nil
        }
        
        guard orderedViewControllers.count > previousIndex else {
            return nil
        }
    
        return orderedViewControllers[previousIndex]
    }

    public func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController?{
        guard let viewControllerIndex = orderedViewControllers.index(of: viewController) else {
            return nil
        }
        let nextIndex = viewControllerIndex + 1
        
        guard orderedViewControllers.count != nextIndex else {
            return nil
        }
        
        guard orderedViewControllers.count > nextIndex else {
            return nil
        }
    
        return orderedViewControllers[nextIndex]
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowFilters" {
            if let navcon = segue.destination as? UINavigationController {
                if let filtersVC = navcon.viewControllers.first as? RecyclePointListViewController {
                    filtersVC.selectedCategories = Set(recyclePointCategories)
                }
            }
        }
    }
    
    @IBAction func cancelFiltersViewController(segue: UIStoryboardSegue) {
        
    }
    
    
    @IBAction func didTouchSearchButtonOnFiltersViewController(segue: UIStoryboardSegue) {
        let vc = segue.source
        if let filterVC = vc as? RecyclePointListViewController {
            recyclePointCategories = Set(filterVC.selectedCategories)
            FiltersModel.sharedModel.categories = recyclePointCategories
            
            RecyclePointsManager.defaultManager.getSelectedRecyclePoints(categories: recyclePointCategories) { (recyclePoints) in
                print(recyclePoints)
            }
        }
    }

    
}



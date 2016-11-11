//
//  CreateCleaningViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 31.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GooglePlaces

class CreateCleaningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SearchResultsDelegate, UISearchBarDelegate {
    let kSearchResultCellIdentifier = "searchResultCell"
    
    @IBOutlet weak var dateAndTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet var addPhotoButtons: [UIButton]!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    var resultArray = [String]()
    let searchController = SearchResultsController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        searchController.delegate = self
        addressSearchBar.delegate = self
        addressSearchBar.layer.borderWidth = 0.01
        addressSearchBar.layer.borderColor = UIColor.white.cgColor
        
        
    }
    
    
    
    
    
    // MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
            }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        return UITableViewCell()
        }
    // MARK: - UITableViewDelegate
    
    // MARK: - UISearchBarDelegate
    
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        if searchBar == self.addressSearchBar {
            let controller = UISearchController(searchResultsController: self.searchController)
            controller.hidesNavigationBarDuringPresentation = true
            controller.searchBar.delegate = self
            controller.searchBar.text = self.addressSearchBar.placeholder
            present(controller, animated: true, completion: nil)
            return false
        }
        return true
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { [unowned self] (results, error:Error?) in
            self.resultArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                self.resultArray.append(result.attributedFullText.string)
            }
            self.searchController.reloadDataWith(Array: self.resultArray)
        }
    }

    // MARK: - Actions
    

    @IBAction func addPhotoButtonDidTapped(_ sender: Any) {
    }
    
    
    // MARK: - LoadData
    // MARK: - SearchResultDelegate
    func pass(longtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
        addressSearchBar.placeholder = title
    }

    
    // MARK: - AutoComplete
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    


    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

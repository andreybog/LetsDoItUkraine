//
//  CreateCleaningViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 31.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GooglePlaces

class CreateCleaningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SearchResultsDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let kSearchResultCellIdentifier = "searchResultCell"

    @IBOutlet weak var dateAndTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet var addPhotoButtons: [UIButton]!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    var resultArray = [String]()
    var buttonTag = Int()
    var cleaningDate = Date()
    var cleaningDescription:String?
    var newCleaning = Cleaning()
    
    let searchController = SearchResultsController()
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)
        imagePicker.delegate = self
        searchController.delegate = self
        addressSearchBar.delegate = self
        
        for button in addPhotoButtons {
            button.setImage(#imageLiteral(resourceName: "PlaceholderCleaningPhoto"), for: UIControlState.normal)
        }
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
    
    @IBAction func addPhotoButtonDidTapped(_ sender: UIButton!) {
        imagePicker.allowsEditing = true
        buttonTag = sender.tag
        print(buttonTag)
        let alert = UIAlertController(title: "Please choose photo", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) {[unowned self] (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) {[unowned self] (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let deleteAction = UIAlertAction(title: "Delete", style: .destructive, handler: { [unowned self] (action) in
            for button in self.addPhotoButtons{
                if button.tag == self.buttonTag {
                    button.setImage(#imageLiteral(resourceName: "PlaceholderCleaningPhoto"), for: UIControlState.normal)
                }
            }
        })
        
        if !(sender.currentImage?.isEqual(#imageLiteral(resourceName: "PlaceholderCleaningPhoto")))! {
            alert.addAction(deleteAction)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }
    
    // MARK: - LoadData
    // MARK: - UIImagePickerControllerDelegate Methods
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        guard let selectedImage = selectedImageFromPicker else {return}
        for button in addPhotoButtons{
            if button.tag == buttonTag {
                button.setImage(selectedImage, for: UIControlState.normal)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - SearchResultDelegate
    func pass(longtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
        addressSearchBar.placeholder = title
    }

    
    // MARK: - UITextFieldDelegate


    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.locale = NSLocale(localeIdentifier: "ru_RU") as Locale
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale(localeIdentifier: "ru_RU") as Locale!
        dateFormatter.dateStyle = .long
        dateFormatter.timeStyle = .short
        dateAndTimeTextField.text = dateFormatter.string(from: sender.date)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

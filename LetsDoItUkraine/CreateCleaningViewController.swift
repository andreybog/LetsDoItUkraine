//
//  CreateCleaningViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton A on 31.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import CoreLocation
import GooglePlaces
import QuartzCore

class CreateCleaningViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, SearchResultsDelegate, UISearchBarDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let kSearchResultCellIdentifier = "searchResultCell"
    let kCleaningPlaceSegue = "cleaningPlaceSegue"
    
    @IBOutlet weak var descriptionButton: UIButton!
    @IBOutlet weak var dateAndTimeTextField: UITextField!
    @IBOutlet weak var descriptionTextField: UITextView!
    @IBOutlet var addPhotoButtons: [UIButton]!
    @IBOutlet weak var addressSearchBar: UISearchBar!
    
    var resultArray = [String]()
    var buttonTag = Int()
    var cleaningDate = Date()
    var cleaningDescription:String?
    var photosUrls = [URL]()
    var coordinate = CLLocationCoordinate2D()
    let searchController = SearchResultsController()
//    var currentUser = User()
    
    
    let imagePicker = UIImagePickerController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationItem.setHidesBackButton(true, animated: false)

        imagePicker.delegate = self
        searchController.delegate = self
        addressSearchBar.delegate = self

        addressSearchBar.layer.borderWidth = 0.01
        addressSearchBar.layer.borderColor = UIColor.white.cgColor
        
        let image = #imageLiteral(resourceName: "location_cl")
        addressSearchBar.setImage(image, for: UISearchBarIcon.search, state: UIControlState.normal)
        for button in addPhotoButtons {
            button.contentMode = .scaleToFill
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
    
    
    
    @IBAction func descriptionButtonDidTapped(_ sender: UIButton) {
        descriptionTextField.becomeFirstResponder()
    }
    
    @IBAction func nextButtonDIdTapped(_ sender: UIButton) {
        let usersManager = UsersManager.defaultManager
        var cleaning = Cleaning()
        
        if let address = addressSearchBar.placeholder {
            cleaning.address = address
        }
        cleaning.coordinate = coordinate
        cleaning.summary = descriptionTextField.text
        cleaning.startAt = cleaningDate
        cleaning.createdAt = Date()
        
        if let currentUser = usersManager.currentUser, usersManager.isCurrentUserCanAddCleaning {
            loadPhotos(photos: addPhotoButtons) { [unowned self] (urls, error) in
                if (error == nil) {
                    cleaning.pictures = urls
                    currentUser.create(cleaning) { (error, cleaning) in
                        //TODO: - segue to cleanings info screen
                    }
                } else {
                    self.showMessageToUser("Ошибка загрузки картинки")
                }
            }
        } else {
            showMessageToUser("Вы не можете создать новую уборку")
        }
    }
    
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
    func loadPhotos (photos:[UIButton], handler: @escaping (_:[URL], _:Error?) -> Void) {
        var urls = [URL]()
        var error:Error?
        let dispatchGroup = DispatchGroup()
        
        
        for photo in photos {
            if !(photo.currentImage?.isEqual(#imageLiteral(resourceName: "PlaceholderCleaningPhoto")))! {
                dispatchGroup.enter()
                ImageLoader.default.upload(image: photo.currentImage!, to: ImageStoragePath.cleanings.rawValue, handler: {
                    (url, err) in
                    if err == nil {
                        if let newUrl = url {
                            urls.append(newUrl)
                        }
                        dispatchGroup.leave()
                    } else {
                        error = err
                        dispatchGroup.leave()
                    }
                })
            }
        }
        
        dispatchGroup.notify(queue: DispatchQueue.main) {
            handler(urls, error)
        }
        
    }
    
    
    
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
                button.contentMode = .scaleToFill
                button.setImage(selectedImage, for: UIControlState.normal)
            }
            dismiss(animated: true, completion: nil)
        }
    }
    
    
    // MARK: - SearchResultDelegate
    func pass(longtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
        coordinate = CLLocationCoordinate2DMake(lat, lon)
        addressSearchBar.placeholder = title
    }
    
    
    // MARK: - UITextFieldDelegate
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        let datePickerView:UIDatePicker = UIDatePicker()
        datePickerView.locale = NSLocale(localeIdentifier: "ru_RU") as Locale
        datePickerView.datePickerMode = UIDatePickerMode.dateAndTime
        textField.inputView = datePickerView
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControlEvents.valueChanged)
        dateAndTimeTextField.text = datePickerView.date.dateWithLocale
    }
    
    func datePickerValueChanged(sender:UIDatePicker) {
        dateAndTimeTextField.text = sender.date.dateWithLocale
        cleaningDate = sender.date
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {

        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func showMessageToUser(_ message: String) {
        let alert = UIAlertController(title:"Создание уборки" , message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
        
    }
    
    //MARK: - Segues
        
}

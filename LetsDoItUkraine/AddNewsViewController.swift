//
//  AddNewsViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 25.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import Kingfisher

class AddNewsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var newsImage: UIImageView!
    
    @IBOutlet weak var newsTitleLabel: UITextField!
    
    @IBOutlet weak var newsBodyLabel: UITextView!
    
    var isSelectedImage = false 
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(AddNewsViewController.newsImageWasTapped))
        newsImage.addGestureRecognizer(tapGesture)
        newsImage.isUserInteractionEnabled = true
        imagePicker.delegate = self
        
    }
    
    func newsImageWasTapped() {
        imagePicker.allowsEditing = true
        
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
            self.newsImage.image = UIImage(named: "placeholder")
            self.isSelectedImage = false
        })
        
        if isSelectedImage {
            alert.addAction(deleteAction)
        }
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        if let editedImage = info[UIImagePickerControllerEditedImage] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        guard let selectedImage = selectedImageFromPicker else {return}
        newsImage.contentMode = .scaleAspectFill
        newsImage.image = selectedImage
        isSelectedImage = true
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}










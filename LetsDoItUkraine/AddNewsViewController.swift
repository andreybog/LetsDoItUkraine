//
//  AddNewsViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 25.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class AddNewsViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    let imagePicker = UIImagePickerController()

    @IBOutlet weak var newsImage: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newsImage.setRounded()

        imagePicker.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    //MARK: UIImagePickerControllerDelegate
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            newsImage.contentMode = .scaleAspectFit
            newsImage.image = pickedImage
        }
        
         dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    
    
    
    @IBAction func loadImageButtonWasTouched() {
        imagePicker.allowsEditing = false
        
        let alert = UIAlertController(title: "Choose photo", message: nil, preferredStyle: .actionSheet)
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.imagePicker.sourceType = .camera
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        
        let libraryAction = UIAlertAction(title: "Library", style: .default) { (action) in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true, completion: nil)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alert.addAction(cameraAction)
        alert.addAction(libraryAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true, completion: nil)
        
    }
    
    
    

}

extension UIImageView {
    
    func setRounded() {
        //self.layer.cornerRadius = 40
        //self.layer.masksToBounds = true
    }
}








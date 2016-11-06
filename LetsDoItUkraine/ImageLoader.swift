//
//  ImageLoader.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 11/6/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FirebaseStorage

class ImageLoader {
    
    static let `default` = ImageLoader()
    
    lazy var rootRef:FIRStorageReference = {
        return FIRStorage.storage().reference()
    }()
    
    func upload(image: UIImage, to folderPath: String, handler: @escaping (_:URL?, _:Error?) -> Void) {
        let imageName = NSUUID().uuidString
        let uploadRef = rootRef.child("\(folderPath)/\(imageName).jpg")
        let metadata = FIRStorageMetadata()
        metadata.contentType = "image/jpeg"
        
        if let data = UIImageJPEGRepresentation(image, 0.4) {
            uploadRef.put(data, metadata: metadata, completion: { (metadata, error) in
                if error != nil {
                    handler(nil, error)
                } else {
                    handler(metadata?.downloadURL(), nil)
                }
            })
        }
    }
}

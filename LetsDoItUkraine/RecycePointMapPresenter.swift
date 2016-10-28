//
//  RecycePointMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation


class RecyclePointMapPresenter {
    
    private let locationManager = LocationManager()
    
    func determineAutorizationStatus(handler: @escaping (_: String) -> Void) {
        self.locationManager.determineAutorizationStatus { (status) in
            handler(status)
        }
    }
}

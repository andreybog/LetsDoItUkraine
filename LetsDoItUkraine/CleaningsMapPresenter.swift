//
//  CleaningsMapPresenter.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/27/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation

//protocol CleaningView {
//    var district: String! { get set }
//    var address: String! {get set}
//    var coordinator : String! {get set}
//    var participants : String! {get set}
//}
//
//extension CleaningsMapCollectionViewCell: CleaningView {
//
//    var district: String! {
//        get {
//            return self.districtLabel.text ?? ""
//        }
//        set {
//            self.districtLabel.text = newValue
//        }
//    }
//    var address: String! {
//        get{
//            return self.addressLabel.text ?? ""
//        }
//        set {
//            self.districtLabel.text = newValue
//        }
//    }
//    var coordinator : String! {
//        get{
//            return self.coordinatorNameLabel.text ?? ""
//        }
//        set {
//            self.coordinatorNameLabel.text = newValue
//        }
//    }
//    var participants : String! {
//        get{
//            return self.participantsNumberLabel.text ?? ""
//        }
//        set {
//            self.participantsNumberLabel.text = newValue
//        }
//    }
//}

protocol CleaningsMapPresentDelegate {
    func didUpdateCleanings()
//    func fillCleaningShortDetails(cleaning:CleaningView, index: Int)
}

class CleaningsMapPresenter {
    
    private let locationManager = LocationManager()
    var delegate : CleaningsMapPresentDelegate!
    private let localityManager = LocalityManager()
    
    private let cleaningsManager = CleaningsManager.defaultManager
    private let usersManager = UsersManager.defaultManager
    
    var cleaningsArray = [Cleaning]()
    var cleaningsCoordinators:[[User]]!
    var cleaningsDistricts = [String]()
    var streetViewImages = [URL?]()
    
    init() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        self.streetViewImages = [URL?](repeatElement(nil, count: cleaningsArray.count))
    }

    
    deinit {
        removeCleaningsObservers()
    }
    
    func loadCleanings() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.cleaningsDistricts = [String](repeatElement("", count: cleaningsArray.count))
        self.streetViewImages = [URL?](repeatElement(nil, count: cleaningsArray.count))
        if cleaningsArray.count > 0 {
            self.fillMemberDistrictArraysAndStreetViewUrl()
            if delegate != nil {
                delegate.didUpdateCleanings()
            }
        }
    }

    private func fillMemberDistrictArraysAndStreetViewUrl() {
        for (index, cleaning) in cleaningsArray.enumerated() {
            if cleaning.coordinatorsIds != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsIds!, handler: { users in
                    self.cleaningsCoordinators[index] = users
                })
            }
            localityManager.searchForSublocalityWith(coordinates: cleaning.coordinate, handler: { (localityName) in
                self.cleaningsDistricts[index] = localityName
            })
            let streetViewFormatter = StreetViewFormatter()
            let urlString = streetViewFormatter.setStreetViewImageWith(coordinates: "\(cleaning.coordinate.latitude), \(cleaning.coordinate.longitude)")
            let url = URL(string: urlString)
            if url != nil {
                self.streetViewImages[index] = url!
            } else {
                self.streetViewImages[index] = nil
            }
        }
    }
    
    func addCleaningsObservers() {
        cleaningsManager.retainObserver()
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(updateCleaningsWith),
                                               name: kCleaningsManagerCleaningModifyNotification,
                                               object: nil)
    }
    
    func removeCleaningsObservers() {
        cleaningsManager.releaseObserver()
        NotificationCenter.default.removeObserver(self, name: kCleaningsManagerCleaningModifyNotification, object: nil)
    }
    
    @objc func updateCleaningsWith(notification:Notification) {
        loadCleanings()
    }
    
    func determineAutorizationStatus(handler: @escaping (_: String) -> Void) {
        self.locationManager.determineAutorizationStatus { (status) in
            handler(status)
        }
    }
}

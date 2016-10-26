//
//  RecyclePointMapViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/25/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class RecyclePointMapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, CLLocationManagerDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recyclePointsCollectionView: UICollectionView!
    
    var recyclePointCategories = Set<RecyclePointCategory>()
    
    var searchMarker = GMSMarker()
    
    var locationManager = CLLocationManager()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        determineAutorizationStatus()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        let layout = self.recyclePointsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20, height: 100)
        recyclePointCategories = FiltersModel.sharedModel.categories
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func setCurrentLocationOnMap(){
        if let mylocation = mapView.myLocation{
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(mylocation.coordinate, zoom: 15))
        } else {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(50.425977, 30.534182), zoom: 12.0))
        }
    }
    
    //MARK: - LocateOnTheMapDelegate
    func locateWith(longtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat, lon)
            self.searchMarker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.mapView.camera = camera
            self.searchMarker.title = title
            self.searchMarker.map = self.mapView
        }
    }
    
    //MARK: - Location Methods
    
    func determineAutorizationStatus() {
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            locationManager.requestWhenInUseAuthorization()
        case .denied:
            showEnableLocationServicesAlert()
        case .authorizedWhenInUse:
            startUpdatingLocation()
        default:
            print("Default")
        }
    }
    
    func showEnableLocationServicesAlert() {
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func startUpdatingLocation() {
        locationManager.startUpdatingLocation()
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
    
    //MARK: - CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        determineAutorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        if currentLocation.horizontalAccuracy < locationManager.desiredAccuracy {
            locationManager.stopUpdatingLocation()
            self.mapView.isMyLocationEnabled = true
            setCurrentLocationOnMap()
        }
    }
    
    
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 3
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recyclePointCell", for: indexPath) as! RecyclePointMapCollectionViewCell
        return cell
    }
    
    //MARK: - UIScrollViewDelegate
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {
        
        let layout = self.recyclePointsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        let cellWithIncludingSpacing = layout.itemSize.width + layout.minimumLineSpacing
        var offset = targetContentOffset.pointee
        let index = (offset.x + scrollView.contentInset.left) / cellWithIncludingSpacing
        let roundedIndex = round(index)
        let currentOffset = scrollView.contentOffset
        let currentOffsetIndex = (currentOffset.x + scrollView.contentInset.left) / cellWithIncludingSpacing
        let roundedIndexOfCurrentOffset = round(currentOffsetIndex)
        if roundedIndex > roundedIndexOfCurrentOffset {
            offset = CGPoint(x: (roundedIndexOfCurrentOffset + 1) * cellWithIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        } else if roundedIndex < roundedIndexOfCurrentOffset {
            offset = CGPoint(x: (roundedIndexOfCurrentOffset - 1) * cellWithIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        } else if roundedIndex == roundedIndexOfCurrentOffset {
            offset = CGPoint(x: roundedIndexOfCurrentOffset * cellWithIncludingSpacing - scrollView.contentInset.left, y: scrollView.contentInset.top)
        }
        targetContentOffset.pointee = offset
    }
    
    @IBAction func cancelFiltersViewController(segue: UIStoryboardSegue) {
        
    }
    
    //RecyclePoints
    
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

//
//  CleaningsViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/9/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class CleaningsViewController: UIViewController,CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, GMSMapViewDelegate {
    //--------Outlets-------------
        //----Buttons----
    @IBOutlet weak var recycleButton: UIButton!
    @IBOutlet weak var cleaningsButton: UIButton!
        //---------------
        //----Views------
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var cleaningsCollectionView: UICollectionView!
        //---------------
    //----------------------------
    //--------Properties----------
    var locationManager = CLLocationManager()
    var currentLocationCoordinates = CLLocationCoordinate2D()
    var cleaningsArray = ["НСК Олимпийский","блвр. Леси Украинки","КНУКМ"]
    //----------------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()

        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        determineAuthorizationStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForegroundNotification), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        styleNavigationBar()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        setMarkers()
        mapView.delegate = self
        self.cleaningsCollectionView.isHidden = true
        self.cleaningsCollectionView.backgroundColor = UIColor.clear
    }
    func setMarkers() {
        let marker1 = GMSMarker(position: CLLocationCoordinate2DMake(50.433197, 30.521941))
        let marker2 = GMSMarker(position: CLLocationCoordinate2DMake(50.432717, 30.535749))
        let marker3 = GMSMarker(position: CLLocationCoordinate2DMake(50.425071, 30.534235))
        marker1.map = mapView
        marker2.map = mapView
        marker3.map = mapView
    }
    
    
    //MARK: Setting Navigation Bar
    
    func styleNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Rectangle"), for: UIBarMetrics.default)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    func handleApplicationWillEnterForegroundNotification(_ notification:Notification) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    //MARK: Location methods
    func determineAuthorizationStatus(){
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

    func showEnableLocationServicesAlert(){
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите сипользовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
        
    }

    func startUpdatingLocation(){
        locationManager.startUpdatingLocation()
    }
    
    func setCurrentLocationOnMap(){
        if let myLocation = mapView.myLocation {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 15))
        } else {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(currentLocationCoordinates, zoom: 15))
        }
    }

    //MARK: CLLocationManagerDelegate
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        determineAuthorizationStatus()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations.last!
        currentLocationCoordinates = currentLocation.coordinate
        if currentLocation.horizontalAccuracy < locationManager.desiredAccuracy {
            locationManager.stopUpdatingLocation()
            self.mapView.isMyLocationEnabled = true
            setCurrentLocationOnMap()
        }
    }
    
    //MARK: GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.padding = UIEdgeInsetsMake(0, 0, 120, 0)
        self.cleaningsCollectionView.isHidden = false
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        self.cleaningsCollectionView.isHidden = true
    }
    
    
    //MARK: UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cleaningsArray.count
    }
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CleaningsMapCollectionViewCell
        return cell
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @IBAction func didTouchSearchButton(_ sender: UIBarButtonItem) {
    }

    @IBAction func didTouchRecycleButton(_ sender: UIButton) {
    }


}

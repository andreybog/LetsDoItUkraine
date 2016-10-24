//
//  CleaningsViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/9/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces


class CleaningsViewController: UIViewController,CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, LocateOnTheMapDelegate, GMSMapViewDelegate {
    
    @IBOutlet weak var segment: UISegmentedControl!
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var cleaningsCollectionView: UICollectionView!
    
    var searchResultController : SearchResultsController!
    var resultArray = [String]()
    var searchMarker = GMSMarker()


    var locationManager = CLLocationManager()
    var currentLocationCoordinates = CLLocationCoordinate2D()
    let cleaningsManager = CleaningsManager.defaultManager
    let usersManager = UsersManager.defaultManager
    var cleaningsArray = [Cleaning]()
    var cleaningsCoordinators:[[User]]!
    
    var transferID = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.delegate = self
        determineAuthorizationStatus()
        NotificationCenter.default.addObserver(self, selector: #selector(handleApplicationWillEnterForegroundNotification),
                                               name: NSNotification.Name.UIApplicationWillEnterForeground,
                                               object: nil)
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        styleNavigationBar()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
//        reloadData()
        
        addCleaningsObservers()

        mapView.delegate = self
        let layout = self.cleaningsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20.0, height: 100)
        self.cleaningsCollectionView.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        removeCleaningsObservers()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        searchResultController = SearchResultsController()
        searchResultController.delegate = self
    }
    
    func reloadData() {
        self.cleaningsArray = [Cleaning](cleaningsManager.activeCleanings.values)
        self.cleaningsCoordinators = [[User]](repeatElement([], count: cleaningsArray.count))
        self.fillMemberArrays()
        self.updateUI()
    }
    
    func updateUI() {
        setMarkers()
        if !cleaningsCollectionView.isHidden {
            cleaningsCollectionView.reloadData()
        }
    }
    
    func fillMemberArrays() {
        for (index, cleaning) in cleaningsArray.enumerated() {
            if cleaning.coordinatorsId != nil {
                usersManager.getUsers(withIds: cleaning.coordinatorsId!, handler: { users in
                    self.cleaningsCoordinators[index] = users
                })
            }
        }
    }
    
    func setMarkers() {
        mapView.clear()
        for cleaning in self.cleaningsArray{
            let marker = GMSMarker(position: cleaning.coordinate)
            marker.icon = GMSMarker.markerImage(with: UIColor.green)
            marker.snippet = cleaning.ID
            marker.map = mapView
        }
    }
    
    func setStreetViewImageWith(coordinates: CLLocationCoordinate2D) -> UIImage?{
        let mainURL = "https://maps.googleapis.com/maps/api/streetview?"
        let size = "300x300"
        let location = "\(coordinates.latitude),%20\(coordinates.longitude)"
        let urlString = "\(mainURL)size=\(size)&location=\(location)&key=\(kGoogleStreetViewAPIKey)"
        guard let url = URL(string: "\(urlString)") else {
            print(urlString)
            print("URL cannot be formed with the string")
            return nil
        }
        let imageData : Data
        do {
            imageData = try Data(contentsOf: url)
        } catch {
            print("No Data by URL")
            return nil
        }
        if let image = UIImage(data: imageData) {
            return image
        } else {
            print("No image while by url data")
            return nil
        }
    }
    
    //MARK: - Setting Navigation Bar
    
    func styleNavigationBar(){
        self.navigationController?.navigationBar.setBackgroundImage(#imageLiteral(resourceName: "Rectangle"), for: UIBarMetrics.default)
    }
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }

    
    //MARK: - Notifications
    
    func addCleaningsObservers() {
        cleaningsManager.retainObserver()
        NotificationCenter.default.addObserver(self, selector: #selector(handleCleaningsModifyNotification),
                                               name: kCleaningsManagerCleaningModifyNotification,
                                               object: nil)
    }
    
    func removeCleaningsObservers() {
        cleaningsManager.releaseObserver()
        NotificationCenter.default.removeObserver(self, name: kCleaningsManagerCleaningModifyNotification, object: nil)
    }
    
    func handleCleaningsModifyNotification(_ notification:Notification) {
        reloadData()
    }
    
    func handleApplicationWillEnterForegroundNotification(_ notification:Notification) {
        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            startUpdatingLocation()
        }
    }
    
    //MARK: - Location methods
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
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
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

    //MARK: - CLLocationManagerDelegate
    
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
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
        
        for (index, cleaning) in cleaningsArray.enumerated() {
            if marker.snippet == cleaning.ID {
                mapView.animate(toLocation: cleaningsArray[index].coordinate)
                mapView.animate(toZoom: 15)
                
                self.cleaningsCollectionView.reloadData()
                self.cleaningsCollectionView.scrollToItem(at:IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                self.cleaningsCollectionView.isHidden = false
                
                break
            }
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        self.cleaningsCollectionView.isHidden = true
        self.searchMarker.map = nil
    }
    
    //MARK: - UICollectionViewDelegate
    
    func collectionView(_ collectionView: UICollectionView, shouldSelectItemAt indexPath: IndexPath) -> Bool {
        self.transferID = cleaningsArray[indexPath.row].ID
        return true
    }
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return cleaningsArray.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CleaningsMapCollectionViewCell
        let index = indexPath.row
        let cleaning = cleaningsArray[index]
        let coordinator = cleaningsCoordinators[index].first!
        let cleanersCount = cleaning.cleanersId != nil ? cleaning.cleanersId!.count : 0
        
        cell.participantsNumberLabel.text = "Пойдет: \(cleanersCount)"
        cell.coordinatorNameLabel.text = "Координатор: \(coordinator.firstName) \(coordinator.lastName!)"

        
        if let image = setStreetViewImageWith(coordinates: cleaning.coordinate) {
            cell.image.image = image
        } else {
            cell.image.image = #imageLiteral(resourceName: "Placeholder")
        }
        
        let rectShape = CAShapeLayer()
        rectShape.bounds = cell.frame
        rectShape.position = cell.center
        rectShape.path = UIBezierPath(roundedRect: cell.bounds,
                                      byRoundingCorners: [.topLeft, .bottomLeft, .topRight, .bottomRight],
                                      cornerRadii: CGSize(width: 10, height: 10)).cgPath
        cell.layer.backgroundColor = UIColor.clear.cgColor
        cell.layer.mask = rectShape
        
        cell.addressLabel.text = cleaning.address

        return cell
    }
    
    
    //MARK: - UISearchBarDelegate
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        let placesClient = GMSPlacesClient()
        placesClient.autocompleteQuery(searchText, bounds: nil, filter: nil) { (results, error:Error?) in
            self.resultArray.removeAll()
            if results == nil {
                return
            }
            for result in results!{
                if let result = result as? GMSAutocompletePrediction{
                    self.resultArray.append(result.attributedFullText.string)
                }
            }
            self.searchResultController.reloadDataWith(Array: self.resultArray)
        }
    }
    
    //MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cleaningDetailsSegue", let cell = sender as? CleaningsMapCollectionViewCell {
            
            let row = self.cleaningsCollectionView.indexPath(for: cell)!.row
            let cleaning = self.cleaningsArray[row]
            let coordinators = self.cleaningsCoordinators[row]
            
            let cleaningDetailsViewController = segue.destination as! CleanPlaceViewController
            cleaningDetailsViewController.cleaning = cleaning
            cleaningDetailsViewController.coordiantors = coordinators
        }
    }

    
    //MARK: - UIScrollViewDelegate
    
    
    
    func scrollViewWillEndDragging(_ scrollView: UIScrollView, withVelocity velocity: CGPoint, targetContentOffset: UnsafeMutablePointer<CGPoint>) {

        let layout = self.cleaningsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mapView.animate(toLocation: cleaningsArray[self.cleaningsCollectionView.indexPathsForVisibleItems.first!.row].coordinate)
        mapView.animate(toZoom: 15)
    }
    
    
    //MARK: - Deinitialisation
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Actions

    @IBAction func didTouchSearchBarButton(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }


    @IBAction func didChangedSegmentControl(_ sender: AnyObject) {
        if (segment.selectedSegmentIndex == 0) {
            
        }
    }
    
    @IBAction func cancelFiltersViewController(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func didTouchSearchButtonOnFiltersViewController(segue: UIStoryboardSegue) {
        let vc = segue.source
        if let filterVC = vc as? RecyclePointListViewController {
            let data = filterVC.selectedCategories
            let manager = RecyclePointsManager()
            manager.getSelectedRecyclePoints(categories: data) { (recyclePoints) in
                //
            }
        }
        
      // save data to NSUserDefaults
        
    }
    



}

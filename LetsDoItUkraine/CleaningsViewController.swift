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


class CleaningsViewController: UIViewController,CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, UISearchBarDelegate, LocateOnTheMapDelegate, GMSMapViewDelegate, CleaningsMapPresentDelegate {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var cleaningsCollectionView: UICollectionView!
    
    //transfer
    var searchResultController : SearchResultsController!
    var resultArray = [String]()
    
    var searchMarker = GMSMarker()
    var presenter = CleaningsMapPresenter()

    override func viewDidLoad() {
        super.viewDidLoad()
        presenter.determineAutorizationStatus { (status) in
            switch status{
            case "Denied":
                self.showEnableLocationServicesAlert()
            default:
                print("Default")
            }
        }
        presenter.delegate = self
        presenter.loadCleanings()
        self.mapView.isMyLocationEnabled = true
        setCurrentLocationOnMap()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        let layout = self.cleaningsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20.0, height: 100)
        //transfer
        searchResultController = SearchResultsController()
        searchResultController.delegate = self

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.cleaningsCollectionView.isHidden = true
    }
    
    func updateUI() {
        setMarkers()
        if !cleaningsCollectionView.isHidden {
            cleaningsCollectionView.reloadData()
        }
    }
    
    private func setMarkers() {
        mapView.clear()
        for cleaning in presenter.cleaningsArray{
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
    
    func showEnableLocationServicesAlert(){
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func setCurrentLocationOnMap(){
        if let myLocation = mapView.myLocation {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 15))
        }else {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(50.425977, 30.534182), zoom: 12))
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
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
        
        for (index, cleaning) in presenter.cleaningsArray.enumerated() {
            if marker.snippet == cleaning.ID {
                mapView.animate(toLocation: presenter.cleaningsArray[index].coordinate)
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
    
    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.cleaningsArray.count
    }
    
    
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CleaningsMapCollectionViewCell
        let index = indexPath.row
        let cleaning = presenter.cleaningsArray[index]
        let coordinator = presenter.cleaningsCoordinators[index].first!
        let district = presenter.cleaningsDistricts[index]
        let cleanersCount = cleaning.cleanersIds != nil ? cleaning.cleanersIds!.count : 0
        cell.districtLabel.text = district
        cell.participantsNumberLabel.text = "Пойдет: \(cleanersCount)"
        cell.coordinatorNameLabel.text = "Координатор: \(coordinator.firstName) \(coordinator.lastName!)"

        
        if let image = setStreetViewImageWith(coordinates: cleaning.coordinate) {
            cell.image.image = image
        } else {
            cell.image.image = #imageLiteral(resourceName: "Placeholder")
        }

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
            let cleaning = presenter.cleaningsArray[row]
            let coordinators = presenter.cleaningsCoordinators[row]
            
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
        mapView.animate(toLocation: presenter.cleaningsArray[self.cleaningsCollectionView.indexPathsForVisibleItems.first!.row].coordinate)
        mapView.animate(toZoom: 15)
    }
    
    //MARK: - Actions

    @IBAction func didTouchSearchBarButton(_ sender: AnyObject) {
        let searchController = UISearchController(searchResultsController: searchResultController)
        searchController.searchBar.delegate = self
        self.present(searchController, animated: true, completion: nil)
    }

}

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


class CleaningsViewController: UIViewController,CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, GMSMapViewDelegate, CleaningsMapPresentDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var cleaningsCollectionView: UICollectionView!
    
    //MARK: - Properties
    var searchMarker = GMSMarker()
    var presenter = CleaningsMapPresenter()
    
    //MARK: - Life Cycle
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
        
        self.mapView.isMyLocationEnabled = true
        
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        
        let layout = self.cleaningsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20.0, height: 100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadCleanings()
        presenter.addCleaningsObservers()
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        self.cleaningsCollectionView.isHidden = true
        self.setCurrentLocationOnMap()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeCleaningsObservers()
    }
    
    //MARK: - Methods
    private func setMarkers() {
        mapView.clear()
        for cleaning in presenter.cleaningsArray{
            let marker = GMSMarker(position: cleaning.coordinate)
            marker.icon = GMSMarker.markerImage(with: UIColor.green)
            marker.snippet = cleaning.ID
            marker.map = mapView
        }
    }
    
    private func setStreetViewImageWith(coordinates: CLLocationCoordinate2D) -> UIImage?{
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
    
    private func showEnableLocationServicesAlert(){
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
        
    }
    
    func setCurrentLocationOnMap(){
        if let myLocation = mapView.myLocation {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(myLocation.coordinate, zoom: 11))
        }else {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(48.6997654,31.9802874), zoom: 4.3))
        }
    }
    
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
    
    //MARK: - CleaningsMapPresentDelegate
    func didUpdateCleanings() {
        setMarkers()
        if !cleaningsCollectionView.isHidden {
            cleaningsCollectionView.reloadData()
        }
    }
    
//    func fillCleaningShortDetails(cleaning:CleaningView, index: Int) {
//        cleaning.address = presenter.cleaningsArray[index].address
//        cleaning.coordinator = "Координатор: \(presenter.cleaningsCoordinators.first?.first?.firstName) \(presenter.cleaningsCoordinators.first?.first?.lastName ?? "")"
//    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
        
        for (index, cleaning) in presenter.cleaningsArray.enumerated() {
            if marker.snippet == cleaning.ID {
                mapView.animate(toLocation: presenter.cleaningsArray[index].coordinate)
                mapView.animate(toZoom: 14)
                
                self.cleaningsCollectionView.reloadData()
                self.cleaningsCollectionView.scrollToItem(at:IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                self.cleaningsCollectionView.isHidden = false
                
                break
            }
        }
        self.searchMarker.map = nil
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
        let coordinators = presenter.cleaningsCoordinators[index]
        cell.coordinatorNameLabel.text = "Координатор: \(coordinators.first?.firstName ?? "") \(coordinators.first?.lastName ?? "")"
        let district = presenter.cleaningsDistricts[index]
        let cleanersCount = cleaning.cleanersIds != nil ? cleaning.cleanersIds!.count : 0
        let url = presenter.streetViewImages[index]
        cell.districtLabel.text = district
        cell.participantsNumberLabel.text = "Пойдет: \(cleanersCount)"
        if url != nil {
            cell.image.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        } else {
            cell.image.image = #imageLiteral(resourceName: "Placeholder")
        }
        cell.addressLabel.text = cleaning.address
        return cell
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
        mapView.animate(toZoom: 14)
    }
}

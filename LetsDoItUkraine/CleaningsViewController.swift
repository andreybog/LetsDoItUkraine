//
//  CleaningsViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/9/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class CleaningsViewController: UIViewController,CLLocationManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource, GMSMapViewDelegate, CleaningsMapPresentDelegate {
    
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var cleaningsCollectionView: UICollectionView!
    
    //MARK: - Properties
    var searchMarker = GMSMarker()
    var presenter = CleaningsMapPresenter()
    let mapManager = MapManager()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        DispatchQueue.main.async {
            switch CLLocationManager.authorizationStatus() {
            case .notDetermined:
                CLLocationManager().requestWhenInUseAuthorization()
            case .denied:
                self.showEnableLocationServicesAlert()
            default:
                print("Default")
            }
        }
        searchMarker.appearAnimation = kGMSMarkerAnimationPop
        presenter.delegate = self
        presenter.loadCleanings()
        mapManager.setup(map: mapView)
        mapView.delegate = self
        self.setUpCollectionViewCellWidth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        mapManager.setCurrentLocationOn(map: mapView)
        self.setCollectionViewVisible(isCollectionViewVisible: false)
    }
    
    
    //MARK: - Methods
    private func setUpCollectionViewCellWidth(){
        let layout = self.cleaningsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20, height: 100)
    }
    
    private func setCollectionViewVisible(isCollectionViewVisible: Bool){
        self.cleaningsCollectionView.isHidden = !isCollectionViewVisible
        mapManager.setPudding(on: isCollectionViewVisible, onMapView: mapView)
    }
    
    func locateOnMapWith(longtitude lon: Double, andLatitude lat: Double, andTitle title: String){
        mapManager.locate(searchMarker: self.searchMarker,onMap: mapView, withLongtitude: lon, andLatitude: lat, andTitle: title)
        self.presenter.prepareCollectionViewWith(Coordinates: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        self.cleaningsCollectionView.reloadData()
        setCollectionViewVisible(isCollectionViewVisible: true)
    }
    
    private func showEnableLocationServicesAlert(){
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        present(alert, animated: true, completion: nil)
    }
    
    //MARK: - CleaningsMapPresentDelegate
    func didUpdateCleanings() {
        mapManager.setMarkersWith(Array: presenter.getCleaningsIdsAndCoordinates(), onMap: mapView)
        if !cleaningsCollectionView.isHidden {
            cleaningsCollectionView.reloadData()
        }
    }
    
    func didUpdateCurrentCleanings() {
        DispatchQueue.main.async {
            if !self.cleaningsCollectionView.isHidden {
                self.cleaningsCollectionView.reloadData()
            }
        }
    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.snippet != nil {
            let coordinate = presenter.prepareCollectionViewAndGetCoordinatesWith(ID: marker.snippet!)
            mapView.animate(toLocation: coordinate)
            mapView.animate(toZoom: 14)
            self.cleaningsCollectionView.reloadData()
            self.cleaningsCollectionView.scrollToItem(at:IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            setCollectionViewVisible(isCollectionViewVisible: true)
            self.searchMarker.map = nil
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if cleaningsCollectionView.isHidden {
            DispatchQueue.main.async {
                self.mapManager.locate(searchMarker: self.searchMarker, onMap: mapView, withCoordinate: coordinate)
            }
            self.presenter.prepareCollectionViewWith(Coordinates: coordinate)
            self.cleaningsCollectionView.reloadData()
            setCollectionViewVisible(isCollectionViewVisible: true)
        } else {
            setCollectionViewVisible(isCollectionViewVisible: false)
            self.searchMarker.map = nil
        }
    }
    
    func mapView(_ mapView: GMSMapView, didLongPressAt coordinate: CLLocationCoordinate2D) {
        DispatchQueue.main.async {
            self.mapManager.locate(searchMarker: self.searchMarker, onMap: mapView, withCoordinate: coordinate)
        }
        self.presenter.prepareCollectionViewWith(Coordinates: coordinate)
        self.cleaningsCollectionView.reloadData()
        setCollectionViewVisible(isCollectionViewVisible: true)
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.animate(toZoom: 14)
        return true
    }
    
    //MARK: - UICollectionViewDataSource
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.cleaningsCount()
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! CleaningsMapCollectionViewCell
        presenter.fillCleaningsShortDetailsIn(Cell: cell, byIndex: indexPath.row)
        let url = presenter.getStreetImageURLViewForCellBy(Index: indexPath.row)
        if url != nil {
            cell.image.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        } else {
            cell.image.image = #imageLiteral(resourceName: "Placeholder")
        }
        return cell
    }
    
    //MARK: - Prepare for Segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "cleaningDetailsSegue", let cell = sender as? CleaningsMapCollectionViewCell {
            let index = self.cleaningsCollectionView.indexPath(for: cell)!.row
            let cleaning = presenter.getCleaningBy(Index: index)
            let coordinators = presenter.getCoordinatorsBy(Index: index)
            let cleanPlaceViewController = segue.destination as! CleanPlaceViewController
            cleanPlaceViewController.cleaning = cleaning!
            cleanPlaceViewController.coordiantors = coordinators!
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
        mapView.animate(toLocation: presenter.getCleaningBy(Index: self.cleaningsCollectionView.indexPathsForVisibleItems.first!.row)!.coordinate)
        mapView.animate(toZoom: 14)
    }
    
    deinit {
        presenter.removeCleaningsObservers()
    }
}

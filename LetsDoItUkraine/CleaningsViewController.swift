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
    let mapManager = MapManager()
    
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
        mapManager.setup(map: mapView)
        mapView.delegate = self
        self.setUpCollectionViewCellWidth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadCleanings()
        presenter.addCleaningsObservers()
        mapManager.setCurrentLocationOn(map: mapView)
        self.setCollectionViewVisible(isCollectionViewVisible: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        presenter.removeCleaningsObservers()
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
    
//    func fillCleaningShortDetails(cleaning:CleaningView, index: Int) {
//        cleaning.address = presenter.cleaningsArray[index].address
//        cleaning.coordinator = "Координатор: \(presenter.cleaningsCoordinators.first?.first?.firstName) \(presenter.cleaningsCoordinators.first?.first?.lastName ?? "")"
//    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        self.setCollectionViewVisible(isCollectionViewVisible: true)
        for (index, cleaning) in presenter.cleaningsArray.enumerated() {
            if marker.snippet == cleaning.ID {
                mapView.animate(toLocation: presenter.cleaningsArray[index].coordinate)
                mapView.animate(toZoom: 14)
                
                self.cleaningsCollectionView.reloadData()
                self.cleaningsCollectionView.scrollToItem(at:IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                break
            }
        }
        self.searchMarker.map = nil
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        self.setCollectionViewVisible(isCollectionViewVisible: false)
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
        
        let district = presenter.cleaningsDistricts[index]
        let cleanersCount = cleaning.cleanersIds != nil ? cleaning.cleanersIds!.count : 0
        let url = presenter.streetViewImages[index]
        cell.districtLabel.text = district
        cell.participantsNumberLabel.text = "Пойдет: \(cleanersCount)"
        if let coordinator = presenter.cleaningsCoordinators[index].first {
            cell.coordinatorNameLabel.text = "Координатор: \(coordinator.firstName) \(coordinator.lastName!)"
        }
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
    
    deinit {
        
    }
}

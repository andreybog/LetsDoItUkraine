//
//  RecyclePointMapViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/25/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class RecyclePointMapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GMSMapViewDelegate, RecyclePointMapPresentDelegate {
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recyclePointsCollectionView: UICollectionView!
    
    //MARK: - Properties
    var searchMarker = GMSMarker()
    let presenter = RecyclePointMapPresenter()
    
    //MARK: - Life cycle
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
        presenter.loadPoints()
        
        self.mapView.isMyLocationEnabled = true
        setCurrentLocationOnMap()
        mapView.settings.compassButton = true
        mapView.settings.myLocationButton = true
        mapView.delegate = self
        let layout = self.recyclePointsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20, height: 100)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        setCurrentLocationOnMap()
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0);
        self.recyclePointsCollectionView.isHidden = true
        presenter.loadPoints()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Methods
    func setMarkers() {
        mapView.clear()
        if presenter.pointsArray.count != 0{
            for point in presenter.pointsArray{
                let marker = GMSMarker(position: point.coordinate)
                marker.icon = GMSMarker.markerImage(with: UIColor.green)
                marker.snippet = point.ID
                marker.map = mapView
            }
        }
    }
    
    func setCurrentLocationOnMap(){
        if let mylocation = mapView.myLocation{
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(mylocation.coordinate, zoom: 15))
        } else {
            self.mapView.moveCamera(GMSCameraUpdate.setTarget(CLLocationCoordinate2DMake(50.425977, 30.534182), zoom: 12.0))
        }
    }
    
    func locateOnMapWith(longtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
        DispatchQueue.main.async {
            let position = CLLocationCoordinate2DMake(lat, lon)
            self.searchMarker = GMSMarker(position: position)
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 15)
            self.mapView.camera = camera
            self.searchMarker.title = title
            self.searchMarker.map = self.mapView
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
    
    //MARK: - RecyclePointMapPresentDelegate
    func didUpdateRecyclePoints(){
        setMarkers()
        recyclePointsCollectionView.reloadData()
    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        mapView.padding = UIEdgeInsetsMake(0, 0, 110, 0)
        
        for (index, point) in presenter.pointsArray.enumerated() {
            if marker.snippet == point.ID {
                mapView.animate(toLocation: presenter.pointsArray[index].coordinate)
                mapView.animate(toZoom: 15)
                
                self.recyclePointsCollectionView.reloadData()
                self.recyclePointsCollectionView.scrollToItem(at:IndexPath(row: index, section: 0), at: .centeredHorizontally, animated: true)
                self.recyclePointsCollectionView.isHidden = false
                
                break
            }
        }
        self.searchMarker.map = nil
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        mapView.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        self.recyclePointsCollectionView.isHidden = true
        self.searchMarker.map = nil
    }
    


    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pointsArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recyclePointCell", for: indexPath) as! RecyclePointMapCollectionViewCell
        cell.recyclePointTitleLabel.text = presenter.pointsArray[indexPath.row].title
        cell.recycleTypeLabel.text = presenter.pointCategories[indexPath.row]
        cell.recyclePointAddressLabel.text = presenter.pointsArray[indexPath.row].address
        if presenter.pointsArray[indexPath.row].schedule != nil{
            cell.RecyclePointWorkingHoursLabel.text = presenter.pointsArray[indexPath.row].schedule
        }
        let url = presenter.pointsURL[indexPath.row]
        if url != nil{
            cell.streetViewImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        } else {
            cell.streetViewImage.image = #imageLiteral(resourceName: "Placeholder")
        }
        let distance = presenter.pointDistances[indexPath.row]
        if distance != nil{
            cell.recyclePointDistanceLabel.text = "\(String(describing: distance!)) km"
        } else {
            cell.recyclePointDistanceLabel.text = ""
        }
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
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        mapView.animate(toLocation: presenter.pointsArray[self.recyclePointsCollectionView.indexPathsForVisibleItems.first!.row].coordinate)
        mapView.animate(toZoom: 15)
    }
    
    //MARK: - Prepare For Segue 
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecyclePointDetailsSegue", let cell = sender as?  RecyclePointMapCollectionViewCell{
            let index = self.recyclePointsCollectionView.indexPath(for: cell)!.row
            let point = presenter.pointsArray[index]
            let recyclePointDetailsViewController = segue.destination as! RecyclePointViewController
            recyclePointDetailsViewController.recyclePoint = point
        }
    }
    
}

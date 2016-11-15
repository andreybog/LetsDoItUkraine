//
//  RecyclePointMapViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/25/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class RecyclePointMapViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, GMSMapViewDelegate, RecyclePointMapPresentDelegate{
    
    //MARK: - Outlets
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var recyclePointsCollectionView: UICollectionView!
    
    @IBOutlet weak var collectionViewLayoutConstraint: NSLayoutConstraint!
    //MARK: - Properties
    var searchMarker = GMSMarker()
    let presenter = RecyclePointMapPresenter()
    let mapManager = MapManager()
    
    //MARK: - Life cycle
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
        mapManager.setup(map: mapView)
        mapView.delegate = self
        self.setUpCollectionViewCellWidth()
        setCollectionViewVisible(isCollectionViewVisible: false)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3, execute: {
            self.mapManager.setCurrentLocationOn(map: self.mapView)
        })
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadPoints()
        if presenter.hasFiltersChanged() {
            self.setCollectionViewVisible(isCollectionViewVisible: false)
            mapManager.setCurrentLocationOn(map: mapView)
            
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    //MARK: - Methods
    private func setUpCollectionViewCellWidth(){
        let layout = self.recyclePointsCollectionView.collectionViewLayout as! UICollectionViewFlowLayout
        layout.itemSize = CGSize(width: self.view.frame.width - 20, height: 100)
    }
    
    private func setCollectionViewVisible(isCollectionViewVisible: Bool){
        var constant : CGFloat = 0.0
        if isCollectionViewVisible {
            constant = 8.0
        } else {
            constant = -100.0
        }
        self.collectionViewLayoutConstraint.constant = constant
        UIView.animate(withDuration: 0.5, animations: {
            self.view.layoutIfNeeded()
            self.mapManager.setPudding(on: isCollectionViewVisible, onMapView: self.mapView)
            
        })
    }
    
    private func showEnableLocationServicesAlert() {
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
    }
    
    func locateOnMapWith(longtitude lon: Double, andLatitude lat: Double, andTitle title: String){
        mapManager.locate(searchMarker: self.searchMarker,onMap: mapView, withLongtitude: lon, andLatitude: lat, andTitle: title)
        self.presenter.prepareCollectionViewWith(Coordinates: CLLocationCoordinate2D(latitude: lat, longitude: lon))
        self.recyclePointsCollectionView.reloadData()
        setCollectionViewVisible(isCollectionViewVisible: true)
        
    }
    
    //MARK: - RecyclePointMapPresentDelegate
    func didUpdateRecyclePoints(){
        mapManager.setMarkersWith(Array: presenter.getPointsIdsAndCoordinates(), onMap: mapView)
        if collectionViewLayoutConstraint.constant > 0 {
            recyclePointsCollectionView.reloadData()
        }
    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.snippet != nil {
            let coordinate = presenter.prepareCollectionViewAndGetCoordinatesWith(ID: marker.snippet!)
            mapManager.moveAt(Coordiante: coordinate, onMap: mapView)
            self.recyclePointsCollectionView.reloadData()
            self.recyclePointsCollectionView.scrollToItem(at:IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            if collectionViewLayoutConstraint.constant < 0{
                setCollectionViewVisible(isCollectionViewVisible: true)
            }
            self.searchMarker.map = nil
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if collectionViewLayoutConstraint.constant < 0{
                DispatchQueue.main.async {
                self.mapManager.locate(searchMarker: self.searchMarker, onMap: mapView, withCoordinate: coordinate)
                }
                self.presenter.prepareCollectionViewWith(Coordinates: coordinate)
                self.recyclePointsCollectionView.reloadData()
                self.setCollectionViewVisible(isCollectionViewVisible: true)
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
        self.recyclePointsCollectionView.reloadData()
        if collectionViewLayoutConstraint.constant < 0 {
            self.setCollectionViewVisible(isCollectionViewVisible: true)
        }
    }
    
    func didTapMyLocationButton(for mapView: GMSMapView) -> Bool {
        mapView.animate(toZoom: 14)
        return false
    }

    //MARK: - UICollectionViewDataSource
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return presenter.pointsCount()
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "recyclePointCell", for: indexPath) as! RecyclePointMapCollectionViewCell
        presenter.fillRecyclePointShortDetailsIn(Cell: cell, byIndex: indexPath.row)
        let url = presenter.getStreetImageURLViewForCellBy(Index: indexPath.row)
        if url != nil{
            cell.streetViewImage.kf.setImage(with: url, placeholder: #imageLiteral(resourceName: "placeholder"))
        } else {
            cell.streetViewImage.image = #imageLiteral(resourceName: "Placeholder")
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
        let coordinate = (presenter.getPointBy(Index: self.recyclePointsCollectionView.indexPathsForVisibleItems.first!.row)?.coordinate)!
        mapManager.moveAt(Coordiante: coordinate, onMap: mapView)
    }
    
    //MARK: - Prepare For Segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "RecyclePointDetailsSegue", let cell = sender as?  RecyclePointMapCollectionViewCell{
            let index = self.recyclePointsCollectionView.indexPath(for: cell)!.row
            let point = presenter.getPointBy(Index: index)!
            let recyclePointDetailsViewController = segue.destination as! RecyclePointViewController
            recyclePointDetailsViewController.recyclePoint = point
        }
    }
}

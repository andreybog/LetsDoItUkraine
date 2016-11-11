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
        presenter.delegate = self
        mapManager.setup(map: mapView)
        mapView.delegate = self
        self.setUpCollectionViewCellWidth()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        presenter.loadPoints()
        mapManager.setCurrentLocationOn(map: mapView)
        setCollectionViewVisible(isCollectionViewVisible: false)
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
        self.recyclePointsCollectionView.isHidden = !isCollectionViewVisible
        mapManager.setPudding(on: isCollectionViewVisible, onMapView: mapView)
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
        if !recyclePointsCollectionView.isHidden {
            recyclePointsCollectionView.reloadData()
        }
    }
    
    //MARK: - GMSMapViewDelegate
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        if marker.snippet != nil {
            let coordinate = presenter.prepareCollectionViewAndGetCoordinatesWith(ID: marker.snippet!)
            mapView.animate(toLocation: coordinate)
            mapView.animate(toZoom: 14)
            self.recyclePointsCollectionView.reloadData()
            self.recyclePointsCollectionView.scrollToItem(at:IndexPath(row: 0, section: 0), at: .centeredHorizontally, animated: true)
            setCollectionViewVisible(isCollectionViewVisible: true)
            self.searchMarker.map = nil
        }
        return true
    }
    
    func mapView(_ mapView: GMSMapView, didTapAt coordinate: CLLocationCoordinate2D) {
        if recyclePointsCollectionView.isHidden{
            if self.searchMarker.map != nil{
                self.searchMarker.map = nil
            } else {
                DispatchQueue.main.async {
                    self.mapManager.locate(searchMarker: self.searchMarker, onMap: mapView, withCoordinate: coordinate)
                }
                self.presenter.prepareCollectionViewWith(Coordinates: coordinate)
                self.recyclePointsCollectionView.reloadData()
                setCollectionViewVisible(isCollectionViewVisible: true)
            }
        } else {
            setCollectionViewVisible(isCollectionViewVisible: false)
            self.searchMarker.map = nil
        }
        
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
        mapView.animate(toLocation: (presenter.getPointBy(Index: self.recyclePointsCollectionView.indexPathsForVisibleItems.first!.row)?.coordinate)!)
        mapView.animate(toZoom: 14)
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

//
//  MapManager.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/2/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import GoogleMaps

protocol MapMangerProtocol {
    var elementCoordinate : CLLocationCoordinate2D { get }
    var elementID : String { get }
}

extension Cleaning : MapMangerProtocol{
    var elementID : String {
        get {
            return self.ID
        }
    }
    var elementCoordinate : CLLocationCoordinate2D {
        get {
            return self.coordinate
        }
    }
}

extension RecyclePoint : MapMangerProtocol{
    var elementID : String {
        get {
            return self.ID
        }
    }
    var elementCoordinate : CLLocationCoordinate2D {
        get {
            return self.coordinate
        }
    }
}

class MapManager {
    
    func setup(map: GMSMapView) {
        map.isMyLocationEnabled = true
        map.settings.compassButton = true
        map.settings.myLocationButton = true
    }
    
    func setCurrentLocationOn(map: GMSMapView){
        if let mylocation = map.myLocation{
            map.animate(toLocation: mylocation.coordinate)
            map.animate(toZoom: 14)
        } else {
            map.animate(toLocation: (CLLocationCoordinate2DMake(48.6997654,31.9802874)))
            map.animate(toZoom: 4.3)
        }
    }
    
    func setMarkersWith(Array elements: [(String, CLLocationCoordinate2D)], onMap map: GMSMapView) {
        map.clear()
        if elements.count != 0{
            for element in elements{
                let marker = GMSMarker(position: element.1)
                marker.icon = GMSMarker.markerImage(with: UIColor(colorLiteralRed: 0.168627450980392, green: 0.835294117647059, blue: 0.588235294117647, alpha: 1))
                marker.snippet = element.0
                marker.appearAnimation = kGMSMarkerAnimationPop
                marker.map = map
            }
        }
    }
    
    func locate(searchMarker marker: GMSMarker, onMap map: GMSMapView, withLongtitude lon: Double, andLatitude lat: Double, andTitle title: String) {
            let position = CLLocationCoordinate2DMake(lat, lon)
            marker.position = position
            let camera = GMSCameraPosition.camera(withLatitude: lat, longitude: lon, zoom: 14)
            map.camera = camera
            marker.title = title
            marker.map = map
    }
    
    func locate(searchMarker marker: GMSMarker, onMap map: GMSMapView, withCoordinate coordinate: CLLocationCoordinate2D) {
        marker.position = coordinate
        marker.map = map
    }
    
    func setPudding(on isPaddingOn: Bool, onMapView map: GMSMapView) {
        if isPaddingOn{
            map.padding = UIEdgeInsetsMake(0, 0, 110, 0)
        } else {
            map.padding = UIEdgeInsetsMake(0, 0, 0, 0)
        }
    }
    
    func moveAt(Coordiante coordinate: CLLocationCoordinate2D, onMap map: GMSMapView) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(0.5)
        map.animate(toLocation: coordinate)
        map.animate(toZoom: 14)
        CATransaction.commit()
    }
    
    func drawDirection(toLocation destination: CLLocationCoordinate2D,withRoute route: String, onMap map: GMSMapView) {
        CATransaction.begin()
        CATransaction.setAnimationDuration(2)
        let path = GMSPath(fromEncodedPath: route)
        let polyline = GMSPolyline(path: path)
        polyline.strokeWidth = 3
        polyline.strokeColor = UIColor.dirtyGreen()
        polyline.map = map
        let cameraUpdate = GMSCameraUpdate.fit(GMSCoordinateBounds(coordinate: (map.myLocation?.coordinate)!, coordinate: destination), with: UIEdgeInsets(top: 80, left: 80, bottom: 80, right: 80))
        map.animate(with: cameraUpdate)
        let destinationMarker = GMSMarker(position: destination)
        destinationMarker.appearAnimation = kGMSMarkerAnimationPop
        destinationMarker.icon = GMSMarker.markerImage(with: UIColor.dirtyGreen())
        destinationMarker.map = map
        CATransaction.commit()
    }

}

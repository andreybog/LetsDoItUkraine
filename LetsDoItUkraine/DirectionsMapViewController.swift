//
//  DirectionsMapViewController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 11/15/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import GoogleMaps

class DirectionsMapViewController: UIViewController {
    
    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var durationLabel: UILabel!
    @IBOutlet weak var informationViewConstraint: NSLayoutConstraint!
    let mapManager = MapManager()
    let directionManager = DirectionManager()
    var information = ("","")
    
    var destinationCoordinates = CLLocationCoordinate2D()
    

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
        self.informationViewConstraint.constant = -48
        self.mapManager.setup(map: self.mapView)
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {[unowned self] in
            self.mapManager.setCurrentLocationOn(map: self.mapView)
    })

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.asyncAfter(deadline: .now() + 1, execute: {[unowned self] in
            self.directionManager.getRouteDataWith(StartPoint: (self.mapView.myLocation?.coordinate)!, andDestinationPoint: self.destinationCoordinates, withHandler: { [unowned self] routeDate in
                self.mapManager.drawDirection(toLocation: self.destinationCoordinates, withRoute: routeDate.0, onMap: self.mapView)
                self.information.0 = routeDate.1
                self.information.1 = routeDate.2
                self.animateInfoView()
            })
        })

    }
    
    func animateInfoView() {
        DispatchQueue.main.async {
            self.distanceLabel.text = self.information.0
            self.durationLabel.text = self.information.1
            self.informationViewConstraint.constant = 8
            UIView.animate(withDuration: 2, animations: {
                self.view.layoutIfNeeded()
                self.mapView.padding = UIEdgeInsetsMake(50, 0, 50, 0)
            })
        }
    }
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    private func showEnableLocationServicesAlert() {
        let alert = UIAlertController(title: "Геопозиция запрещена пользователем для этого приложения.", message: "Если вы хотите использовать карты, пожалуйста, разрешите использование геопозиции в настройках приложения.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Отменить", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Открыть настройки", style: .default) { (action) in
            UIApplication.shared.openURL(URL(string: UIApplicationOpenSettingsURLString)!)
        })
        
        present(alert, animated: true, completion: nil)
    }
}

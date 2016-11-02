//
//  RecyclePoint.swift
//  LetsDoItUkraine
//
//  Created by user on 06.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

enum RecyclePointCategory: String {
    case Plastic = "plastic"
    case WastePaper = "paper"
    case Glass = "glass"
    case Mercury = "mercury"
    case Battery = "battery"
    case OldThings = "oldStuff"
    case Polythene = "polyethylene"
    case Different = "other"
    case All = "all"
    
    var literal: String {
        switch self {
            case .Plastic: return "Пластик"
            case .WastePaper: return "Макулатура"
            case .Glass: return "Стеклобой"
            case .Mercury: return "Ртуть"
            case .Battery: return "Батарейки"
            case .OldThings: return "Старые вещи"
            case .Polythene: return "Полиэтилен"
            default: return "Разное"
        }
    }
}

struct RecyclePoint : CustomStringConvertible {
    var ID: String
    var title: String
    var phone: String?
    var website: String?
    var logo: URL?
    var picture: URL?
    var coordinate: CLLocationCoordinate2D
    var address: String
    var schedule: String?
    var summary: String?
    var categories: Set<RecyclePointCategory>
  
  var description: String {
    return "RECYCLE POINT: - \(ID) - \(title)\n" +
    "location: \(coordinate.latitude), \(coordinate.longitude)\n" +
    "\(categories)"
  }
  
  init() {
    ID = "[no id]"
    title = "[no title]"
    address = "[no address]"
    categories = []
    coordinate = CLLocationCoordinate2D()
  }
}

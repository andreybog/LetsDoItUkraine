//
//  DataGenerator.swift
//  LetsDoItUkraine
//
//  Created by Andrey Bogushev on 10/16/16.
//  Copyright © 2016 goit. All rights reserved.
//

import Foundation
import CoreLocation

private let firstNames = ["Brinda", "Paola", "Robbie", "Floretta", "Natasha", "Mindy", "Sasha", "Shirleen", "Cherrie",
                  "Zenaida", "Vania", "Oscar", "Olen", "Indira", "Maisha", "Asha", "Jayna", "Krystle", "Marleen",
                  "Maye", "Amie", "Christeen", "Armanda", "Rosena", "Tawnya", "Glenna", "Roma", "Fidelia",
                  "Iesha", "Stephine", "Brittanie", "Maryland", "Clarisa", "Antonette", "Stefania", "Jeffie",
                  "Janel", "Edris", "Verlie", "Percy", "Elvira", "Tammie", "Etta", "Graham", "Carly", "Cornell",
                  "Brooke", "Amy", "Kelsey", "Lissa"]
private let lastNames = ["Mansir", "Precourt", "Adkison", "Orear", "Sprow", "Tulloch", "Ausmus", "Dittrich", "Bostrom",
                         "Liming", "Gallion", "Gibby", "Woodward", "Miers", "Campanella", "Galan", "Cummings", "Zakrzewski",
                         "Archambeault", "Krohn", "Hilgefort", "Duncanson", "Garson", "Ellsworth", "Mccurry", "Mccay", "Espiritu",
                         "Ardon", "Brunt", "Lucarelli", "Marine", "Meltzer", "Lafreniere", "Morency", "Pitcher", "Staley", "Blalock",
                         "Mejia", "Notter", "Voit", "Huseby", "Dorr", "Grasser", "Wilkey", "Engebretson", "Brunke", "Mastroianni",
                         "Dockery", "Barbera", "Shearin"]
private let emailDomains = ["yahoo.com", "gmail.com", "meta.ua", "icloud.com", "mail.ua", "rambler.ua", "hcf.com.ua", "adobe.com"]

private let cities = ["Vinnytsia", "Dnipropetrovsk", "Donetsk", "Zhytomyr", "Zaporizhzhia", "Frankivsk",
                      "Kyiv", "Kirovohrad", "Luhansk", "Lutsk", "Lviv", "Mykolaiv", "Odesa", "Poltava",
                      "Rivne", "Sevastopol", "Simferopol", "Sumy", "Ternopil", "Uzhhorod", "Kharkiv",
                      "Kherson", "Khmelnytskyi", "Cherkasy", "Chernivtsi", "Chernihiv"]

enum KyivCoordinate {
  enum Latitude: Double {
    case max = 50.524277
    case min = 50.396584
  }
  enum Longitude: Double {
    case max = 30.629718
    case min = 30.441435
  }
}

class DataGenerator {
//  var users: [User] = []
//  var cleanings: [Cleaning] = []
  
  static let sharedGenerator = DataGenerator()
  private let dataManager = DataManager.sharedManager
  

  func generateUsersAndSave() {
    let users = randomUsers()
    
    users.forEach { (user) in
      UsersManager.defaultManager.createUser(user)
    }
  }
  
  func generateCleaningsAndSave() {
    let cleanings = randomCleanings()
    
    UsersManager.defaultManager.getAllUsers { [unowned self] (users) in
      if !users.isEmpty {
        for cleaning in cleanings {
          let user = self.randomElement(users)
          CleaningsManager.defaultManager.createCleaning(cleaning, byCoordinator: user)
        }
      }
    }
  }
  
  func addCleaningMembers() {
    let start = Date()
    UsersManager.defaultManager.getAllUsers { (users) in
      if !users.isEmpty {
        
        CleaningsManager.defaultManager.getCleanings(filer: .active, with: { [unowned self] (cleanings) in
          if !cleanings.isEmpty {
            
            cleanings.forEach({ (cleaning) in
              let cleanersCount = 10 + Int(arc4random_uniform(20))
              
              for _ in 0..<cleanersCount {
                let user = self.randomElement(users)
                CleaningsManager.defaultManager.addMember(user, toCleaning: cleaning, as: .cleaner)
              }
            })
          }
          print("time past: \(-start.timeIntervalSinceNow)")
        })
      }
    }
  }
  
  
  func randomCleanings() -> [Cleaning] {
    var cleanings = [Cleaning]()
    for _ in 0..<50 {
      var cleaning = Cleaning()
      
      cleaning.isActive = true
      cleaning.datetime = Date(timeIntervalSinceNow: Double(arc4random_uniform(3600*24*30*2)))
      cleaning.cooridnate = randomCoordinate()
      
      cleanings.append(cleaning)
    }
    return cleanings
  }
  
  
  func randomUsers() -> [User] {
    var users = [User]()
    for _ in 0..<5_000 {
      var user = User()
      
      user.firstName = randomElement(firstNames)
      user.lastName = randomElement(lastNames)
      user.email = "\(user.lastName!).\(user.firstName[user.firstName.startIndex])@\(randomElement(emailDomains))"
      user.phone = randomPhone()
      user.country = "Ukraine"
      user.city = randomElement(cities)
      
      users.append(user)
    }
    return users
  }
  
  private func randomElement<T>(_ arr:[T]) -> T {
    return arr[Int(arc4random_uniform(UInt32(arr.count)))]

  }
  
  private func randomDate(maxTimeInterval: TimeInterval, since date: Date) -> Date {
    let timeInterval = Double(arc4random_uniform(UInt32(maxTimeInterval)))
    return Date(timeInterval: timeInterval, since: date)
  }
  
  private func randomCoordinate() -> CLLocationCoordinate2D {
    return randomCoordinate(latitudeRange: (min: KyivCoordinate.Latitude.min.rawValue, max: KyivCoordinate.Latitude.max.rawValue),
                            longitudeRange: (min: KyivCoordinate.Longitude.min.rawValue, max: KyivCoordinate.Longitude.max.rawValue))
  }
  
  private func randomCoordinate(latitudeRange: (min:Double, max:Double),
                                longitudeRange: (min:Double, max:Double)) -> CLLocationCoordinate2D {
    
    let precision:Double = 1_000_000
    let latiutdeDiff = latitudeRange.max * precision - latitudeRange.min * precision
    let longitudeDiff = longitudeRange.max * precision - longitudeRange.min * precision
    
    let latitudeOffset = Double(arc4random_uniform(UInt32(latiutdeDiff))) / precision
    let longitudeOffset = Double(arc4random_uniform(UInt32(longitudeDiff))) / precision
    
    return CLLocationCoordinate2D(latitude: latitudeRange.min + latitudeOffset,
                                  longitude: longitudeRange.min + longitudeOffset)
    
  }
  
  private func randomPhone() -> String {
    var phone = "+38 044 "
    for _ in 0..<7 {
      phone += String(arc4random_uniform(10))
    }
    return phone
  }
}

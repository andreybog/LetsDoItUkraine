//
//  SearchResultsController.swift
//  LetsDoItUkraine
//
//  Created by Anton Aleksieiev on 10/18/16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit


protocol SearchResultsDelegate {
    func pass(longtitude lon:Double, andLatitude lat: Double, andTitle title: String)
}

class SearchResultsController: UITableViewController {

    var searchResults : [String]!
    var delegate : SearchResultsDelegate!
    
    func reloadDataWith(Array array: [String]){
        self.searchResults = array
        self.tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.searchResults = Array()
        self.tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellIdentifier")
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.searchResults.count
    }


    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cellIdentifier", for: indexPath)

        cell.textLabel?.text = self.searchResults[indexPath.row]
        
        return cell
    }

    // MARK: - Table view delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.dismiss(animated: true, completion: nil)
        let correctedAddress:String! = self.searchResults[indexPath.row].addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        let urlString = "https://maps.googleapis.com/maps/api/geocode/json?address=\(correctedAddress!)&sensor=false"
        let url = URL(string: "\(urlString)")
        let task = URLSession.shared.dataTask(with: url!) { (data, responce, error) in
            if error != nil{
                print(error!)
            }else {
                do {
                    if data != nil{
                        let dic = try JSONSerialization.jsonObject(with: data!, options: .mutableLeaves) as! NSDictionary
                        let dictionaryResults = dic["results"] as! [[String:AnyObject]]
                        let resultsGeometry = dictionaryResults.first?["geometry"] as! [String:AnyObject]
                        let location = resultsGeometry["location"] as! [String:AnyObject]
                        let lat = location["lat"] as! Double
                        let lon = location["lng"] as! Double
                        self.delegate.pass(longtitude: lon, andLatitude: lat, andTitle: self.searchResults[indexPath.row])
                    }
                } catch {
                    print("Error")
                }
            }
        }
        task.resume()
    }



}

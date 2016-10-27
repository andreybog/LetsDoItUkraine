//
//  NewsViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 25.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit

class NewsListViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    
    var news = [News]() {
        didSet {
            tableView.reloadData()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        showLoadingState()
        NewsManager.defaultManager.getAllNews { (news) in
            self.news = news
            self.showContent()
        }

    }
    
    func showLoadingState() {
        tableView.isHidden = true
        activityIndicator.isHidden = false
        activityIndicator.startAnimating()
    }
    
    func showContent() {
        tableView.isHidden = false
        activityIndicator.isHidden = true
        activityIndicator.stopAnimating()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    //MARK: - UITableViewDataSource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return news.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NewsCell", for: indexPath) as! NewsTableViewCell
        let newsItem = news[indexPath.row]
        cell.newsImage.kf.setImage(with: newsItem.url,
                                   placeholder: UIImage(named: "placeholder"),
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
        cell.newsTitle.text = newsItem.title
        cell.newsBody.text = newsItem.body
        
        
        if let rowDate = newsItem.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            cell.newsDate.text = formatter.string(from: rowDate)
        }
        return cell
        
    }
    

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        guard let identifier = segue.identifier, identifier == "ShowNewsItem" else { return }
        guard let destination = segue.destination as? NewsItemViewController else { return }
        guard let cell = sender as? NewsTableViewCell else { return }
        guard let indexPath = self.tableView.indexPath(for: cell) else {return}
        let newsItem = self.news[indexPath.row]
        destination.newsItem = newsItem
    }
    
    
    
    @IBAction func createNews(segue: UIStoryboardSegue) {
        
    }
    
    @IBAction func cancelAddNewsViewController(segue: UIStoryboardSegue) {
        
    }

}













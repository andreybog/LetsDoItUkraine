//
//  NewsViewController.swift
//  LetsDoItUkraine
//
//  Created by user on 25.10.16.
//  Copyright © 2016 goit. All rights reserved.
//

import UIKit
import FBSDKShareKit
import FirebaseStorage
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
        
//        showLoadingState()
//        NewsManager.defaultManager.getAllNews {[weak weakSelf = self] (news) in
//            weakSelf?.news = news
//            weakSelf?.showContent()
//        }
        
        showLoadingState()
        NewsManager.defaultManager.getNews(filter: .confirmed) { [unowned self](news) in
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
        cell.newsImage.kf.setImage(with: newsItem.picture,
                                   placeholder: UIImage(named: "placeholder"),
                                   options: nil,
                                   progressBlock: nil,
                                   completionHandler: nil)
        cell.newsTitle.text = newsItem.title
        cell.newsBody.text = newsItem.body
        print(newsItem.picture)
        
        if let rowDate = newsItem.date {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd MMMM yyyy"
            formatter.timeZone = TimeZone(abbreviation: "UTC + 2")
            cell.newsDate.text = formatter.string(from: rowDate)
        }
        cell.shareButton.tag = indexPath.row
        cell.shareButton.addTarget(self, action: #selector(NewsListViewController.shareButtonWasTouched), for: .touchUpInside)
        return cell
        
    }
    
    func shareButtonWasTouched(sender: UIButton) {
        let newsItem = news[sender.tag]
        
        var activityItems = [Any]()
        activityItems.append(newsItem.title)
        
        
        if let url = newsItem.url {
            activityItems.append(url)
        }
        if let newsBody = newsItem.body {
            activityItems.append(newsBody)
        }
        if let picture = newsItem.picture {
            activityItems.append(picture)
        }

        
        let activityVC = UIActivityViewController(activityItems: activityItems, applicationActivities: nil)
        activityVC.excludedActivityTypes = [UIActivityType.airDrop]
        
        present(activityVC, animated: true, completion: nil)
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
        guard let createNewsVC = segue.source as? AddNewsViewController else { return }
        
        let imageName = NSUUID().uuidString
        let storageRef = FIRStorage.storage().reference().child("News_images").child("\(imageName).png")
        
        var news = News()
        
        if let image = createNewsVC.newsImage.image, createNewsVC.isSelectedImage {
            if let uploadData = UIImagePNGRepresentation(image) {
                storageRef.put(uploadData, metadata: nil, completion: {[unowned self] (metadata, error) in
                    if error != nil {
                        self.showMessageToUser()
                        return
                    }
                    guard let title = createNewsVC.newsTitleLabel.text, !title.isEmpty else { return }
                    news.title = title
                    news.body = createNewsVC.newsBodyLabel.text
                    news.picture = metadata?.downloadURL()?.absoluteURL
                    let date = Date()
                    news.date = date
                    
                    NewsManager.defaultManager.createNews(news)
                })
            }
        } else {
            guard let title = createNewsVC.newsTitleLabel.text, !title.isEmpty else { return }
            news.title = title
            news.body = createNewsVC.newsBodyLabel.text
            let date = Date()
            news.date = date
            NewsManager.defaultManager.createNews(news)
        }
        
    }
    
    @IBAction func cancelAddNewsViewController(segue: UIStoryboardSegue) {
        
    }
    
    func showMessageToUser() {
        let alert = UIAlertController(title:"Загрузка изображения" , message: "Не удалось загрузить изображение", preferredStyle: .alert)
        let action = UIAlertAction(title: "Закрыть", style: .cancel, handler: nil)
        alert.addAction(action)
        present(alert, animated: true, completion: nil)
    }

}













//
//  HomeTableViewController.swift
//  Twitter
//
//  Created by Mariam Adams on 10/8/20.
//  Copyright © 2020 Dan. All rights reserved.
//

import UIKit

class HomeTableViewController: UITableViewController {

    var tweetArr = [NSDictionary]()
    var numOfTweets: Int!
    
    let myRefreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadTweets()
        
        myRefreshControl.addTarget(self, action: #selector(loadTweets), for: .valueChanged)
        tableView.refreshControl = myRefreshControl
    }
    
    @objc func loadTweets(){
        numOfTweets = 20
        let tweetURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetURL, parameters: params, success: { (tweets: [NSDictionary]) in
            print("tweets = ", tweets)
            self.tweetArr.removeAll()
            for tweet in tweets{
                self.tweetArr.append(tweet)
            }
            //table updates
            self.tableView.reloadData()
            self.myRefreshControl.endRefreshing()
        }, failure: { (Error) in
            print("could not load tweets")
        })
    }
    
    func loadMoreTweets(){
        numOfTweets = numOfTweets + 20
        let tweetURL = "https://api.twitter.com/1.1/statuses/home_timeline.json"
        let params = ["count": numOfTweets]
        TwitterAPICaller.client?.getDictionariesRequest(url: tweetURL, parameters: params, success: { (tweets: [NSDictionary]) in
            print("tweets = ", tweets)
            self.tweetArr.removeAll()
            for tweet in tweets{
                self.tweetArr.append(tweet)
            }
            //table updates
            self.tableView.reloadData()
        }, failure: { (Error) in
            print("could not load tweets")
        })
    }
    
    
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row + 1 == tweetArr.count{
            loadMoreTweets()
        }
    }
    
    
    @IBAction func onLogout(_ sender: Any) {
        TwitterAPICaller.client?.logout()
        self.dismiss(animated: true, completion: nil)
        UserDefaults.standard.set(false, forKey: "userLoggedIn")
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "tweetCell", for: indexPath) as! TweetCellTableViewCell
        
        let user = tweetArr[indexPath.row]["user"] as! NSDictionary
        
        cell.userNameLabel.text = user["name"] as? String
        cell.tweetLabel.text = tweetArr[indexPath.row]["text"] as? String
        
        let imageURL = URL(string: (user["profile_image_url_https"]as? String)!)
        let data = try? Data(contentsOf: imageURL!)
        
        if let imageData = data{
            cell.profilePicView.image = UIImage(data: imageData)
        }
        return cell
    }
    
    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return tweetArr.count
    }

}

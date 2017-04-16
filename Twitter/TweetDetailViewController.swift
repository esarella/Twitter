//
//  TweetDetailViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/15/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

enum TweetTableStructure: Int {
    case detail = 0, stats, buttons
}

class TweetDetailViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tweetDetail: UITableView!
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tweetDetail.dataSource = self
        tweetDetail.delegate = self
        
        tweetDetail.estimatedRowHeight = 500
        tweetDetail.rowHeight = UITableViewAutomaticDimension
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TweetTableStructure(rawValue:indexPath.section)! {
        case .detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetDetailsTableViewCell", for: indexPath) as! TweetDetailsTableViewCell
            cell.tweet = tweet
            return cell
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetStatusCell", for: indexPath) as! TweetStatusCell
            cell.tweet = tweet
            return cell
        case .buttons:
            let cell = tableView.dequeueReusableCell(withIdentifier: "TweetControlsCell", for: indexPath) as! TweetControlsCell
//            cell.delegate = self
//            cell.tweet = tweet
            return cell
            
        }
    }
    
    
}

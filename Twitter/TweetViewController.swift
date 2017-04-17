//
//  TweetViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit
import RKDropdownAlert

enum TweetTableStructure: Int {
    case detail = 0, stats, buttons
}

class TweetViewController: UIViewController {

    fileprivate let detailCellIdentifier = "TweetDetailCell"
    fileprivate let statsCellIdentifier = "TweetStatsCell"
    fileprivate let buttonsCellIdentifier = "TweetButtonsCell"
    fileprivate let replySegue = "ReplyModalSegue"
    
    @IBOutlet weak var tweetTableView: UITableView!
    
    var tweet: Tweet!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureRowHeight()
        self.navigationController?.navigationBar.tintColor = UIColor.flatBlue
    }

    fileprivate func configureRowHeight() {
        tweetTableView.estimatedRowHeight = 500
        tweetTableView.rowHeight = UITableViewAutomaticDimension
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == replySegue {
            let destinationNavVC = segue.destination as! UINavigationController
            let destinationVC = destinationNavVC.topViewController as! ComposeViewController
            destinationVC.user = User.currentUser
            destinationVC.replyToUser = tweet.user
            destinationVC.tweet = tweet
        }
    }
}
extension TweetViewController: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch TweetTableStructure(rawValue:section)! {
        case .detail, .buttons:
            return 1
        case .stats:
            if let retweetData = tweet.retweetData {
                return (retweetData.favoritesCount == 0 && retweetData.retweetCount == 0) ? 0 : 1
            } else {
                return (tweet.favoritesCount == 0 && tweet.retweetCount == 0) ? 0 : 1
            }
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch TweetTableStructure(rawValue:indexPath.section)! {
        case .detail:
            let cell = tableView.dequeueReusableCell(withIdentifier: detailCellIdentifier, for: indexPath) as! TweetDetailCell
            cell.tweet = tweet
            return cell
        case .stats:
            let cell = tableView.dequeueReusableCell(withIdentifier: statsCellIdentifier, for: indexPath) as! TweetStatsCell
            cell.tweet = tweet
            return cell
        case .buttons:
            let cell = tableView.dequeueReusableCell(withIdentifier: buttonsCellIdentifier, for: indexPath) as! TweetButtonsCell
            cell.delegate = self
            cell.tweet = tweet
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        switch TweetTableStructure(rawValue: indexPath.section)! {
        case .detail, .stats, .buttons:
            return false
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch TweetTableStructure(rawValue: indexPath.section)! {
        case .detail, .stats, .buttons:
            
            tweetTableView.deselectRow(at: indexPath, animated: true)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

extension TweetViewController: TweetButtonsCellDelegate {
    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didFavorited value: Bool) {
        
        switch value {
        case true:
            DispatchQueue.global(qos: .background).async {
                
                self.tweet.didFavorited(success: { (dictionary: NSDictionary, URLResponse: URLResponse?) in
                    if let response = (URLResponse as? HTTPURLResponse)?.statusCode {
                        if response == 200 {
                            self.tweet.getTweetInfo(success: { (newTweet: Tweet) in
                                DispatchQueue.main.async {
                                    self.tweet = newTweet
                                    self.tweetTableView.reloadData()
                                }
                            }, failure: { (error: Error) in
                                DispatchQueue.main.async {
                                    self.showRKDropDown(type: "Error", message: "Failed to Refresh Tweet: \(error.localizedDescription)")
                                }
                            })
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: StaticText.favoritedSuccess), object: nil, userInfo: nil)
                        } else {
                            DispatchQueue.main.async {
                                self.showRKDropDown(type: "Error", message: "Failed to Favorite Tweet with Code: \(response)")
                                self.tweetTableView.reloadData()
                            }
                        }
                    }
                }, failure: { (error: Error) in
                    DispatchQueue.main.async {
                        self.showRKDropDown(type: "Error", message: "Failed to Favorite Tweet with Error: \(error.localizedDescription)")
                        self.tweetTableView.reloadData()
                    }
                })
            }
            
        case false:
            DispatchQueue.global(qos: .background).async {
                
                self.tweet.didUnfavorited(success: { (dictionary: NSDictionary, URLResponse: URLResponse?) in
                    if let response = (URLResponse as? HTTPURLResponse)?.statusCode {
                        if response == 200 {
                            self.tweet.getTweetInfo(success: { (newTweet: Tweet) in
                                DispatchQueue.main.async {
                                    self.tweet = newTweet
                                    self.tweetTableView.reloadData()
                                }
                            }, failure: { (error: Error) in
                                DispatchQueue.main.async {
                                    self.showRKDropDown(type: "Error", message: "Failed to Refresh Tweet: \(error.localizedDescription)")
                                }
                            })
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: StaticText.unFavoritedSuccess), object: nil, userInfo: nil)
                        } else {
                            DispatchQueue.main.async {
                                self.showRKDropDown(type: "Error", message: "Failed to Unfavorite Tweet with Code: \(response)")
                                self.tweetTableView.reloadData()
                            }
                        }
                    }
                }, failure: { (error: Error) in
                    DispatchQueue.main.async {
                        self.showRKDropDown(type: "Error", message: "Failed to Unfavorite Tweet with Error: \(error.localizedDescription)")
                        self.tweetTableView.reloadData()
                    }
                })
            }
        }
    }
    
    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, didRetweeted value: Bool) {
        switch value {
        case true:
            DispatchQueue.global(qos: .background).async {
                
                self.tweet.didRetweeted(success: { (tweet: Tweet, URLResponse: URLResponse?) in
                    if let response = (URLResponse as? HTTPURLResponse)?.statusCode {
                        if response == 200 {
                            self.tweet.getTweetInfo(success: { (newTweet: Tweet) in
                                DispatchQueue.main.async {
                                    self.tweet = newTweet
                                    self.tweetTableView.reloadData()
                                }
                            }, failure: { (error: Error) in
                                DispatchQueue.main.async {
                                    self.showRKDropDown(type: "Error", message: "Failed to Refresh Tweet: \(error.localizedDescription)")
                                }
                            })
                            NotificationCenter.default.post(name: NSNotification.Name(rawValue: StaticText.retweetSuccess), object: nil, userInfo: nil)
                        } else {
                            DispatchQueue.main.async {
                                self.showRKDropDown(type: "Error", message: "Failed to Retweet Tweet with Code: \(response)")
                                self.tweetTableView.reloadData()
                            }
                        }
                    }
                }, failure: { (error: Error) in
                    DispatchQueue.main.async {
                        self.showRKDropDown(type: "Error", message: "Failed to Retweet Tweet with Error: \(error.localizedDescription)")
                        self.tweetTableView.reloadData()
                    }
                })
            }
            
        case false:
            var originalTweetIDStr = ""
            if !tweet.retweeted {
                showRKDropDown(type: "Error", message: "You Have Not Retweeted This Tweet")
                tweetTableView.reloadData() // reset tweet VC
            } else {
                originalTweetIDStr = tweet.retweetData == nil ? tweet.IDString! : tweet.retweetData!.IDString!
            }
            
            DispatchQueue.global(qos: .background).async {
                TwitterClient.sharedInstance.getTweetInfoWithRetweet(ID: originalTweetIDStr, includeMyRetweet: true, success: { (dictionary: NSDictionary) in
                    
                    if let currentUserRetweet = dictionary[TweetParams.currentUserRetweet] as? NSDictionary {
                        let retweetID = currentUserRetweet[TweetParams.tweetIDString] as? String
                        
                        TwitterClient.sharedInstance.postUnretweet(ID: retweetID!, success: { (tweet: Tweet, URLResponse: URLResponse?) in
                            if let response = (URLResponse as? HTTPURLResponse)?.statusCode {
                                if response == 200 {
                                    self.tweet.getTweetInfo(success: { (newTweet: Tweet) in
                                        DispatchQueue.main.async {
                                            self.tweet = newTweet
                                            self.tweetTableView.reloadData()
                                        }
                                    }, failure: { (error: Error) in
                                        DispatchQueue.main.async {
                                            self.showRKDropDown(type: "Error", message: "Failed to Refresh Tweet: \(error.localizedDescription)")
                                        }
                                    })
                                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: StaticText.unRetweetSuccess), object: nil, userInfo: nil)
                                } else {
                                    DispatchQueue.main.async {
                                        self.showRKDropDown(type: "Error", message: "Failed to Unretweet Tweet: Response Code \(response)")
                                        self.tweetTableView.reloadData()
                                    }
                                }
                            }
                        }, failure: { (error: Error) in
                            DispatchQueue.main.async {
                                self.showRKDropDown(type: "Error", message: "Failed to Unretweet Tweet: \(error.localizedDescription)")
                                self.tweetTableView.reloadData()
                            }
                        })
                    } else {
                        DispatchQueue.main.async {
                            self.showRKDropDown(type: "Error", message: "Current User Retweet Not Returned")
                            self.tweetTableView.reloadData()
                        }
                    }
                    
                }, failure: { (error: Error) in
                    DispatchQueue.main.async {
                        self.showRKDropDown(type: "Error", message: "Failed to Unretweet Tweet: \(error.localizedDescription)")
                        self.tweetTableView.reloadData()
                    }
                })
            }
        }
    }
    
    fileprivate func showRKDropDown(type: String, message: String) {
        RKDropdownAlert.title(type, message: message, backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
    }
    
    func tweetButtonsCell(_ tweetButtonsCell: TweetButtonsCell, replyTo tweet: Tweet) {
        self.performSegue(withIdentifier: replySegue, sender: nil)
    }
}

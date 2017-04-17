//
//  TweetsViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit
import SVProgressHUD
import RKDropdownAlert
import SVPullToRefresh
import ChameleonFramework

class TweetsViewController: UIViewController {

    fileprivate let composeSegue = "ComposeModalSegue"
    fileprivate let detailSegue = "DetailPushSegue"

    @IBOutlet weak var tableView: UITableView!

    var tweets: [Tweet]!
    var tempTweets: [Tweet]!
    var currentUser: User!

    override func viewDidLoad() {
        super.viewDidLoad()
        configureRowHeight()
        initialLoadingCacheThenReload()
        addRefreshControl()
        subscribeToNotifications()

        // Add infinite scrolling
        tableView.addInfiniteScrolling {
            self.insertRowsAtBottom()
        }
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @IBAction func onLogoutButton(_ sender: UIBarButtonItem) {
        TwitterClient.sharedInstance.logout()
    }

    fileprivate func initialLoadingCacheThenReload() {
        fetchTweetsFromCache(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()

            SVProgressHUD.show()
            self.fetchTweetsReloadDontLoad(success: { (tweets: [Tweet]) in
                SVProgressHUD.dismiss()
                self.tweets = tweets
                self.tableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.dismiss()
                self.showRKDropDown(type: "Error: \(error.localizedDescription)", message: "Please Try Again Later")
            })
        }, failure: { (error: Error) in

            // Try to reload from client
            SVProgressHUD.show()
            self.fetchTweetsReloadDontLoad(success: { (tweets: [Tweet]) in
                SVProgressHUD.dismiss()
                self.tweets = tweets
                self.tableView.reloadData()
            }, failure: { (error: Error) in
                SVProgressHUD.dismiss()
                self.showRKDropDown(type: "Error: \(error.localizedDescription)", message: "Please Try Again Later")
            })
        })
    }

    fileprivate func addRefreshControl() {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(refreshControlAction(refreshControl:)), for: UIControlEvents.valueChanged)
        tableView.insertSubview(refreshControl, at: 0)
    }

    fileprivate func fetchTweets(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        TwitterClient.sharedInstance.homeTimeline(success: success, failure: failure)
    }

    fileprivate func fetchTweetsForInfiniteLoading(parameters: [String: Any], success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        TwitterClient.sharedInstance.homeTimelineWithParameters(parameters: parameters, success: success, failure: failure)
    }

    fileprivate func fetchTweetsReloadDontLoad(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        let sharedInstance = TwitterClient.sharedInstance
        sharedInstance.requestSerializer.cachePolicy = .reloadIgnoringLocalCacheData
        sharedInstance.homeTimeline(success: success, failure: failure)
    }

    fileprivate func fetchTweetsFromCache(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        let sharedInstance = TwitterClient.sharedInstance
        sharedInstance.requestSerializer.cachePolicy = .returnCacheDataDontLoad
        sharedInstance.homeTimeline(success: success, failure: failure)
    }

    @objc fileprivate func refreshControlAction(refreshControl: UIRefreshControl) {
        fetchTweets(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
            refreshControl.endRefreshing()
        }, failure: { (error: Error) in
            RKDropdownAlert.title("Failed to Refresh Data", message: error.localizedDescription, backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
            refreshControl.endRefreshing()
        })
    }

    fileprivate func configureRowHeight() {
        tableView.estimatedRowHeight = 120
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    @objc fileprivate func refreshDataSuccessNotifications(notification: Notification) {
        fetchTweets(success: { (tweets: [Tweet]) in
            self.tweets = tweets
            self.tableView.reloadData()
        }, failure: { (error: Error) in
            RKDropdownAlert.title("Error: Table Refresh", message: "\(notification.description): \(error.localizedDescription)", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.successBackgroundColor, time: 2)
        })
    }

    @objc fileprivate func subscribeToNotifications() {
        let notificationCenter = NotificationCenter.default

        notificationCenter.addObserver(self, selector: #selector(refreshDataSuccessNotifications(notification:)), name: NSNotification.Name(rawValue: StaticText.favoritedSuccess), object: nil)
        notificationCenter.addObserver(self, selector: #selector(refreshDataSuccessNotifications(notification:)), name: NSNotification.Name(rawValue: StaticText.unFavoritedSuccess), object: nil)
        notificationCenter.addObserver(self, selector: #selector(refreshDataSuccessNotifications(notification:)), name: NSNotification.Name(rawValue: StaticText.retweetSuccess), object: nil)
        notificationCenter.addObserver(self, selector: #selector(refreshDataSuccessNotifications(notification:)), name: NSNotification.Name(rawValue: StaticText.unRetweetSuccess), object: nil)
    }

    fileprivate func showRKDropDown(type: String, message: String) {
        RKDropdownAlert.title(type, message: message, backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
    }

    fileprivate func insertRowsAtBottom() {
        var tempIDArray = [String]()
        if let tweets = self.tweets {
            for tweet in tweets {
                tempIDArray.append(tweet.IDString!)
            }

            if let maxIDStr = tempIDArray.min() {
                let newMaxID = Int64(maxIDStr)! - 1
                fetchTweetsForInfiniteLoading(parameters: [TweetParams.maxID: "\(newMaxID)"], success: { (newTweets: [Tweet]) in
                    self.tweets = self.tweets + newTweets
                    self.tableView.reloadData()
                    self.tableView.infiniteScrollingView.stopAnimating()
                }, failure: { (error: Error) in
                    self.showRKDropDown(type: "Error", message: "Failed to load more data: \(error.localizedDescription)")
                    self.tableView.infiniteScrollingView.stopAnimating()
                })
            }
        } else {
            fetchTweets(success: { (tweets: [Tweet]) in
                self.tweets = tweets
                self.tableView.reloadData()
                self.tableView.infiniteScrollingView.stopAnimating()
            }, failure: { (error: Error) in
                self.showRKDropDown(type: "Error", message: "Failed to fetch data: \(error.localizedDescription)")
                self.tableView.infiniteScrollingView.stopAnimating()
            })
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == detailSegue {
            let indexPath = tableView.indexPath(for: sender as! TweetCell)
            let destinationVC = segue.destination as! TweetViewController
            if let indexPath = indexPath {
                let tweet = tweets[indexPath.row]
                destinationVC.tweet = tweet
            }
        } else if segue.identifier == composeSegue {
            let destinationNavVC = segue.destination as! UINavigationController
            let destinationVC = destinationNavVC.topViewController as! ComposeViewController
            destinationVC.user = currentUser

            destinationVC.postTweet = { (tweet: Tweet) in
                self.tempTweets = self.tweets
                self.tweets.insert(tweet, at: 0)
                self.tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .none)
                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = false
                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.alpha = 0.5

                SVProgressHUD.show()
                DispatchQueue.global(qos: .background).async {
                    // Post the tweet
                    TwitterClient.sharedInstance.postStatus(text: tweet.text!, inReplyToStatusID: nil, success: { (tweet: Tweet) in
                        // Success - reload table
                        self.fetchTweets(success: { (tweets: [Tweet]) in
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                self.tweets = tweets
                                self.tableView.reloadData()
                                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = true
                            }
                        }, failure: { (error: Error) in
                            // Display error
                            DispatchQueue.main.async {
                                SVProgressHUD.dismiss()
                                RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                                self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = true
                            }
                        })
                    }, failure: { (error: Error) in
                        DispatchQueue.main.async {
                            SVProgressHUD.dismiss()
                            RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: ChameleonColors.failureBackgroundColor, textColor: ChameleonColors.failureTextColor, time: 1)
                            self.tableView.cellForRow(at: IndexPath(row: 0, section: 0))?.isUserInteractionEnabled = true
                        }
                    })
                }
            }
        }
    }
}

extension TweetsViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return tweets?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "TweetCell", for: indexPath) as! TweetCell
        cell.tweet = tweets[indexPath.row]
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 0.1
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0.1
    }
}

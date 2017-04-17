//
//  TwitterClient.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

enum loginError: Error {
    case requestTokenNil
    case badURL(String)
}

class TwitterClient: BDBOAuth1SessionManager {


    var loginSuccess: ((User) -> ())?
    var loginFailure: ((Error) -> ())?

    static let sharedInstance = TwitterClient(baseURL: URL(string: StaticText.twitterBaseURL), consumerKey: StaticText.consumerKey, consumerSecret: StaticText.consumerSecret)!

    class func createDateFormatter() -> DateFormatter {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
        dateFormatter.dateStyle = .short
        dateFormatter.timeStyle = .none
        return dateFormatter
    }

    // Handle login process
    func login(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        loginSuccess = success
        loginFailure = failure

        // Deauthorize Before Authorize
        deauthorize()

        // Fetch request token & Login
        fetchRequestToken(withPath: StaticText.requestTokenUrl, method: "GET", callbackURL: URL(string: StaticText.callbackURL), scope: nil, success: { (requestToken: BDBOAuth1Credential?) in

            if let requestToken = requestToken, let token = requestToken.token {
                let urlString = StaticText.twitterBaseURL + StaticText.authorizeUrl + token
                if let authURL = URL(string: urlString), UIApplication.shared.canOpenURL(authURL) {
                    UIApplication.shared.open(authURL, options: [:], completionHandler: nil)
                } else {
                    self.loginFailure?(loginError.badURL(urlString))
                }
            } else {
                self.loginFailure?(loginError.requestTokenNil)
            }
        }) { (error: Error?) in
            self.loginFailure?(error!)
        }
    }

    // Handle open URL
    func openURL(_ url: URL) {

        let queryString = url.query ?? ""
        let requestToken = BDBOAuth1Credential(queryString: queryString)

        if let requestToken = requestToken {
            fetchAccessToken(withPath: StaticText.accessTokenUrl, method: "POST", requestToken: requestToken, success: { (accessToken: BDBOAuth1Credential?) in
                print("Got the access token")
                self.requestSerializer.saveAccessToken(accessToken!)

                self.currentAccount(success: { (user: User) in
                    User.currentUser = user
                    self.loginSuccess?(user)
                }, failure: { (error: Error) in
                    self.loginFailure?(error)
                })
            }) { (error: Error?) in
                print("Failed to get the access token. Error: \(error?.localizedDescription)")
                self.loginFailure?(error!)
            }
        } else {
            loginFailure?(loginError.requestTokenNil)
        }
    }

    // Handle logout process
    func logout() {
        User.currentUser = nil
        deauthorize()
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: User.userDidLogout), object: nil)
    }

    // Fetch current account user
    func currentAccount(success: @escaping (User) -> (), failure: @escaping (Error) -> ()) {
        self.get(StaticText.getUserDataUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let user = User(dictionary: response as! NSDictionary)
            success(user)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Fetch home timeline
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        self.get(StaticText.getHomeTimelineUrl, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func homeTimelineWithParameters(parameters: [String: Any], success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        self.get(StaticText.getHomeTimelineUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any) in
            let tweets = Tweet.tweetsWithArray(response as! [NSDictionary])
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post statuses/update
    func postStatus(text: String, inReplyToStatusID: String?, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        var parameters = [TweetParams.status: text]
        if let ID = inReplyToStatusID {
            parameters[TweetParams.inReplyToStatusID] = ID
        }

        self.post(StaticText.postStatusUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post favorite
    // 200 OK response means it's successful
    func postFavorite(ID: String, success: @escaping (NSDictionary, URLResponse?) -> (), failure: @escaping (Error) -> ()) {
        let parameters = [TweetParams.ID: ID]

        self.post(StaticText.postFavoritesUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success(response as! NSDictionary, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Unpost favorite
    // 200 OK response means it's successful
    func postUnfavorite(ID: String, success: @escaping (NSDictionary, URLResponse?) -> (), failure: @escaping (Error) -> ()) {
        let parameters = [TweetParams.ID: ID]

        self.post(StaticText.postUnfavoritesUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in

            success(response as! NSDictionary, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Post retweet
    func postRetweet(ID: String, success: @escaping (Tweet, URLResponse?) -> (), failure: @escaping (Error) -> ()) {
        let endpoint = StaticText.postRetweetUrl.replacingOccurrences(of: ":id", with: ID)

        self.post(endpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    // Unpost retweet
    func postUnretweet(ID: String, success: @escaping (Tweet, URLResponse?) -> (), failure: @escaping (Error) -> ()) {
        let endpoint = StaticText.postUnretweetUrl.replacingOccurrences(of: ":id", with: ID)

        self.post(endpoint, parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet, task.response)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func getTweetInfo(ID: String, success: @escaping (Tweet) -> (), failure: @escaping (Error) -> ()) {
        let parameters = [TweetParams.ID: ID]//, TwitterClient.Parameters.includeMyRetweet : includeMyRetweet]

        self.get(StaticText.getStatusInfoUrl, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            let tweet = Tweet(dictionary: response as! NSDictionary)
            success(tweet)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }

    func getTweetInfoWithRetweet(ID: String, includeMyRetweet: Bool, success: @escaping (NSDictionary) -> (), failure: @escaping (Error) -> ()) {
        let parameters = [TweetParams.includeMyRetweet: includeMyRetweet]
        let endpoint = StaticText.getStatusInfoWithMyRetweetUrl.replacingOccurrences(of: ":id", with: ID)

        self.get(endpoint, parameters: parameters, progress: nil, success: { (task: URLSessionDataTask, response: Any?) in
            success(response as! NSDictionary)
        }, failure: { (task: URLSessionDataTask?, error: Error) in
            failure(error)
        })
    }
}

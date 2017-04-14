//
//  TwitterClient.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/13/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class TwitterClient: BDBOAuth1SessionManager {
    
    static let url: URL = URL(string: "https://api.twitter.com")!
    static let consumerKey: String = "Xta54Mr1zYTycOZuDSaGNtbUl"
    static let consumerSecret: String = "xphVOZZq3PPWlH7wHyt0YPcZ3CjA9nOfGVJE5aw8yR0LYEwORb"
    
    static let sharedInstance = TwitterClient(baseURL: url as URL!, consumerKey: consumerKey, consumerSecret: consumerSecret)
    
    var loginSucess : (() -> ())?
    var loginFailure: ((Error) -> ())?
    
    func login(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
        loginSucess = success
        loginFailure = failure
        
        //Deauthorize before we get a new token
        TwitterClient.sharedInstance?.deauthorize()
        
        TwitterClient.sharedInstance?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success:
            { (requestToken: BDBOAuth1Credential!)  in
                print("Sucess!! I got a token!")
                print(requestToken.token)
                let url: URL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")!
                
                let temp: [String: Any]  = [:]
                UIApplication.shared.open(url, options: temp, completionHandler: nil)
        }) { (error: Error!) in
            print("error: \(error.localizedDescription)")
            self.loginFailure!(error)
        }
        
    }
    
    func handleOpenUrl(url: URL) {
        let requestToken = BDBOAuth1Credential(queryString: url.query)
        
        fetchAccessToken(withPath: "oauth/access_token",
                         method: "POST",
                         requestToken: requestToken,
                         success: { (accessToken: BDBOAuth1Credential!) in
                            self.loginSucess?()
                            
        }) { (error: Error!) in
            print("error: \(error.localizedDescription)")
            self.loginFailure!(error)
        }
    }
    
    func homeTimeline(success: @escaping ([Tweet]) -> (), failure: @escaping (Error) -> ()) {
        get("1.1/statuses/home_timeline.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            //                                                let tweets = response as! [NSDictionary]
            let dictionaries = response as! [NSDictionary]
            let tweets = Tweet.tweetsWithArray(dictionaries: dictionaries)
            
            success(tweets)
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            failure(error)
        })
    }
    
    func currentAccount() {
        get("1.1/account/verify_credentials.json", parameters: nil, progress: nil, success: { (task: URLSessionDataTask, response: Any?) -> Void in
            //                                                print("account: \(response)")
            let userDictionary = response as! NSDictionary
            let user = User(dictionary: userDictionary)
            
            print("name: \(user.name!)")
            print("screen_name: \(user.screenName!)")
            print("profile_image_url_https: \(user.profileUrl!)")
            print("description: \(user.userDescription!)")
            
            
        }, failure: { (task: URLSessionDataTask?, error: Error) -> Void in
            print("error: \(error.localizedDescription)")
        })
        
    }
}

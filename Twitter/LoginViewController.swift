//
//  LoginViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/13/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import BDBOAuth1Manager

class LoginViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func onLoginTapped(_ sender: Any) {
        
        print("Login Tapped")
        let url: URL = URL(string: "https://api.twitter.com")!
        let consumerKey: String = "Y0SJql28CbzeoOneVmx530Iqn"
        let consumerSecret: String = "prv3Xd6fJiRHLNq3xFDpCSkJjFJ2Amqg7h5qzvfsTAR8SqYMa9"
        
        let twitterClient = BDBOAuth1SessionManager(baseURL: url as URL!, consumerKey: consumerKey, consumerSecret: consumerSecret)
        
        //Deauthorize before we get a new token
        twitterClient?.deauthorize()
        
        twitterClient?.fetchRequestToken(withPath: "oauth/request_token", method: "GET", callbackURL: URL(string: "twitterdemo://oauth"), scope: nil, success:
            { (requestToken: BDBOAuth1Credential!) -> Void in
                print("Sucess!! I got a token!")
                print(requestToken.token)
                let url: URL = URL(string: "https://api.twitter.com/oauth/authorize?oauth_token=\(requestToken.token!)")!
                
                let temp: [String: Any]  = [:]
                UIApplication.shared.open(url, options: temp, completionHandler: nil)
        }) { (error: Error!) -> Void in
            print("error: \(error.localizedDescription)")
        }
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}

//
//  LoginViewController.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import Foundation
import UIKit
import BDBOAuth1Manager
import RKDropdownAlert


import UIKit
import BDBOAuth1Manager
import RKDropdownAlert

class LoginViewController: UIViewController {
    var currentUser: User!

    @IBAction func onLoginButton(_ sender: UIButton) {
        TwitterClient.sharedInstance.login(success: { (user: User) in
            self.currentUser = user
            debugPrint("current user in LoginViewController is \(self.currentUser)")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
        }) { (error: Error) in
//            RKDropdownAlert.title("Error: \(error.localizedDescription)", message: "Please Try Again Later", backgroundColor: TwitterClient.Colors.failureBackgroundColor, textColor: TwitterClient.Colors.failureTextColor, time: 1)
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        let destinationNavVC = segue.destination as! UINavigationController
        let destinationVC = destinationNavVC.topViewController as! TweetsViewController
        destinationVC.currentUser = currentUser
    }
}

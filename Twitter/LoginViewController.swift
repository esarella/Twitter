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
    TwitterClient.sharedInstance?.login(success: {
             // do something
            print("I've Logged in !")
            self.performSegue(withIdentifier: "loginSegue", sender: nil)
            
        }, failure: { (error: Error) in
            print("Error: \(error.localizedDescription)")
        })
        
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

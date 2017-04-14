//
//  User.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/13/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class User: NSObject {
    
    var name : String?
    var screenName: String?
    var profileUrl: URL?
    var userDescription: String?
    
    init(dictionary: NSDictionary) {
        name = dictionary["name"] as? String
        screenName = dictionary["screen_name"] as? String
        
        let profileUrlString = dictionary["profile_image_url_https"] as? String
        if let profileUrlString = profileUrlString {
            profileUrl = URL(string: profileUrlString)
        }
        
        userDescription = dictionary["description"] as? String
        
    }

}

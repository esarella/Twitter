//
//  User.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/16/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class User: NSObject {

    // MARK: - Properties

    var name: String?
    var screenName: String?
    var profileImageURLString: String?
    var profileOriginalImageURLString: String?
    var profileImageURL: URL?
    var tagline: String?
    var dictionary: NSDictionary?

    static let userDidLogout = "UserDidLogout"
    fileprivate static let defaults = UserDefaults.standard
    fileprivate static let currentUserData = "currentUserData"
    fileprivate static var _currentUser: User?

    class var currentUser: User? {
        get {
            if _currentUser == nil {
                let userData = defaults.object(forKey: currentUserData) as? Data

                if let userData = userData {
                    let dictionary = try! JSONSerialization.jsonObject(with: userData, options: []) as! NSDictionary
                    _currentUser = User(dictionary: dictionary)
                }
            }
            return _currentUser
        }
        set(user) {
            _currentUser = user

            if let user = user {
                let userData = try! JSONSerialization.data(withJSONObject: user.dictionary!, options: [])
                defaults.set(userData, forKey: currentUserData)
            } else {
                defaults.removeObject(forKey: currentUserData)
            }
            defaults.synchronize()
        }
    }

    init(dictionary: NSDictionary) {
        self.dictionary = dictionary

        name = dictionary[TweetParams.name] as? String
        screenName = dictionary[TweetParams.screenName] as? String

        if let profileURLString = dictionary[TweetParams.profileImageURL] as? String {
            self.profileImageURLString = profileURLString
            profileOriginalImageURLString = profileImageURLString?.replacingOccurrences(of: "_normal", with: "")
            profileImageURL = profileOriginalImageURLString != nil ? URL(string: profileOriginalImageURLString!) : URL(string: profileURLString)
        }

        tagline = dictionary[TweetParams.tagline] as? String
    }
}


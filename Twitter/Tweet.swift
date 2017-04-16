//
//  Tweet.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/13/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class Tweet: NSObject {
    
    var text: String?
    var timeStamp: Date?
    var timestampString: String?
    var timestampLongString: String?
    var retweetCount: Int = 0
    var favoriteCount: Int = 0
    var user: User?
    var retweetData: Tweet?
    var retweeted: Bool = false
    var favorited: Bool = false

    
    var formattedDate: String {
        if let timeStamp = timeStamp {
            let dateComponentsFormatter = DateComponentsFormatter()
            dateComponentsFormatter.allowedUnits = [.year,.month,.weekOfYear,.day,.hour,.minute,.second]
            dateComponentsFormatter.maximumUnitCount = 1
            dateComponentsFormatter.unitsStyle = .abbreviated
            return dateComponentsFormatter.string(from: timeStamp, to: Date()) ?? ""
        }
        return ""
    }

    
    init(dictionary: NSDictionary) {
        user = User(dictionary: dictionary["user"] as! NSDictionary)
        text = dictionary["text"] as? String
        
        let timeStampString = dictionary["created_at"] as? String
        if let timeStampString = timeStampString {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEE MMM d HH:mm:ss Z y"
            timeStamp = formatter.date(from: timeStampString)
            
            formatter.dateStyle = .short
            formatter.timeStyle = .none
            timestampString = timeStamp == nil ? "" : formatter.string(from: timeStamp!)
            
            formatter.dateStyle = .short
            formatter.timeStyle = .short
            timestampLongString = timeStamp == nil ? "" : formatter.string(from: timeStamp!)
        }
        
        retweetCount = (dictionary["retweet_count"] as? Int) ?? 0
        favoriteCount = (dictionary["favourites_count"] as? Int) ?? 0
        retweeted = (dictionary["retweeted"] as? Bool) ?? false
        favorited = (dictionary["favorited"] as? Bool) ?? false
        
        if let retweetedStatus = dictionary["retweeted_status"] as? NSDictionary {
            retweetData = Tweet(dictionary: retweetedStatus)
        }
    }
    
    class func tweetsWithArray(dictionaries: [NSDictionary]) -> [Tweet] {
        var tweets: [Tweet] = [Tweet]()
        
        for dictionary in dictionaries {
            let tweet = Tweet(dictionary: dictionary)
            tweets.append(tweet)
        }
        
        return tweets
    }
}

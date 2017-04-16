//
//  TweetControlsCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/15/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

protocol TweetControlsCellDelegate: class {
    func tweetControlsCell(_ tweetControlsCell: TweetControlsCell, didFavorited value: Bool)
    func tweetControlsCell(_ tweetControlsCell: TweetControlsCell, didRetweeted value: Bool)
    func tweetControlsCell(_ tweetControlsCell: TweetControlsCell, replyTo tweet: Tweet)
}

class TweetControlsCell: UITableViewCell {

    @IBOutlet weak var replyButton: UIButton!
    @IBOutlet weak var retweetButton: UIButton!
    @IBOutlet weak var favoriteButton: UIButton!
    
    var retweetStatus: Bool!
    var favoritedStatus: Bool!
    weak var delegate: TweetControlsCellDelegate?
    
    var tweet: Tweet! {
        didSet {
            retweetStatus = tweet.retweeted
            favoritedStatus = tweet.favorited
            
            if tweet.favorited {
                debugPrint("favoritedStatus: \(favoritedStatus)")
                favoriteButton.setImage(UIImage(named: "Twitter Like Action On"), for: .normal)
                favoriteButton.setImage(UIImage(named: "Twitter Like Action On Pressed"), for: .highlighted)
            } else {
                favoriteButton.setImage(UIImage(named: "Twitter Like Action"), for: .normal)
                favoriteButton.setImage(UIImage(named: "Twitter Like Action Pressed"), for: .highlighted)
            }
            
            if tweet.retweeted {
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action On"), for: .normal)
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action On Pressed"), for: .highlighted)
            } else {
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action"), for: .normal)
                retweetButton.setImage(UIImage(named: "Twitter Retweet Action Pressed"), for: .highlighted)
            }
        }
    }
    
    @IBAction func replyButtonTapped(_ sender: Any) {
        delegate?.tweetControlsCell(self, replyTo: tweet)
    }
    
    @IBAction func retweetButtonTapped(_ sender: Any) {
        if !retweetStatus {
            retweetStatus = !retweetStatus
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action On"), for: .normal)
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action On Pressed"), for: .highlighted)
        } else {
            retweetStatus = !retweetStatus
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action"), for: .normal)
            retweetButton.setImage(UIImage(named: "Twitter Retweet Action Pressed"), for: .highlighted)
        }
        delegate?.tweetControlsCell(self, didRetweeted: retweetStatus)

    }

    @IBAction func favoriteButtonTapped(_ sender: Any) {
        if !favoritedStatus {
            favoritedStatus = !favoritedStatus
            favoriteButton.setImage(UIImage(named: "Twitter Like Action On"), for: .normal)
            favoriteButton.setImage(UIImage(named: "Twitter Like Action On Pressed"), for: .highlighted)
        } else {
            favoritedStatus = !favoritedStatus
            favoriteButton.setImage(UIImage(named: "Twitter Like Action"), for: .normal)
            favoriteButton.setImage(UIImage(named: "Twitter Like Action Pressed"), for: .highlighted)
        }
        delegate?.tweetControlsCell(self, didFavorited: favoritedStatus)
    }

}

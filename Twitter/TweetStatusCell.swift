//
//  TweetStatusCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/15/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class TweetStatusCell: UITableViewCell {

    @IBOutlet weak var retweetsCountLabel: UILabel!
    @IBOutlet weak var retweetsLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var likesLabel: UILabel!
    
    var tweet: Tweet! {
        didSet {
            if let retweetData = tweet.retweetData {
                retweetsCountLabel.text = retweetData.retweetCount == 0 ? "0" : "\(retweetData.retweetCount)"
                retweetsCountLabel.text = retweetData.favoriteCount == 0 ? "0" :"\(retweetData.favoriteCount)"
                //retweetsLabel.isHidden = retweetData.retweetCount == 0
                //likesLabel.isHidden = retweetData.favoritesCount == 0
            } else {
                retweetsCountLabel.text = tweet.retweetCount == 0 ? "0" : "\(tweet.retweetCount)"
                likesCountLabel.text = tweet.favoriteCount == 0 ? "0" :"\(tweet.favoriteCount)"
                //retweetsLabel.isHidden = tweet.retweetCount == 0
                //likesLabel.isHidden = tweet.favoritesCount == 0
            }
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }

}

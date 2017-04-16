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
                likesCountLabel.text = retweetData.favoriteCount == 0 ? "0" :"\(retweetData.favoriteCount)"
            } else {
                retweetsCountLabel.text = tweet.retweetCount == 0 ? "0" : "\(tweet.retweetCount)"
                likesCountLabel.text = tweet.favoriteCount == 0 ? "0" :"\(tweet.favoriteCount)"
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

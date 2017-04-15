//
//  TweetTableViewCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/13/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit
import AFNetworking

class TweetTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tweetAvatar: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var timeStampLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    
    var tweet: Tweet! {
        didSet{
            if let user = tweet.user {
                nameLabel.text = user.name
                screenNameLabel.text = "@\(user.screenName!)"
                timeStampLabel.text = tweet.formattedDate
                tweetTextLabel.text = tweet.text
                
                if let profileUrl = user.profileUrl {
                    tweetAvatar.setImageWith(profileUrl, placeholderImage: UIImage(named: "DefaultTwitter"))
                } else {
                    tweetAvatar.image = UIImage(named: "DefaultTwitter")
                }
            }
            else {
                
                debugPrint("In Else")
                nameLabel.text = "not set"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    
}

//
//  TweetDetailsTableViewCell.swift
//  Twitter
//
//  Created by Emmanuel Sarella on 4/15/17.
//  Copyright © 2017 Emmanuel Sarella. All rights reserved.
//

import UIKit

class TweetDetailsTableViewCell: UITableViewCell {

    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var screenNameLabel: UILabel!
    @IBOutlet weak var tweetTextLabel: UILabel!
    @IBOutlet weak var tweetImageView: UIImageView!
    @IBOutlet weak var timeStampLabel: UILabel!
    
    var tweet: Tweet! {
    
        didSet{
            if let user = tweet.user {
                nameLabel.text = user.name
                screenNameLabel.text = "@\(user.screenName!)"
                tweetTextLabel.text = tweet.text
                
                if let profileUrl = user.profileUrl {
                    avatarImageView.setImageWith(profileUrl, placeholderImage: UIImage(named: "DefaultTwitter"))
                } else {
                    avatarImageView.image = UIImage(named: "DefaultTwitter")
                }
                
                timeStampLabel.text = tweet.timestampLongString
                //print(tweet.timestampLongString)
                
//                if let mediaURLString = tweet.entities?.medias?[0].mediaURLString {
//                    tweetImageView.setImageWith(URL(string: "\(mediaURLString):large")!)
//                    debugPrint("I get into mediaURLString regular tweet")
//                } else {
//                    tweetImageView.isHidden = true
//                    debugPrint(tweet.entities?.medias?[0].mediaURLString ?? "No media URL String")
//                }
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

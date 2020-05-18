//
//  TweetTableViewCell.swift
//  CarlosTweets
//
//  Created by Carlos Petit on 17-05-20.
//  Copyright © 2020 Carlos Petit. All rights reserved.
//

import UIKit
import Kingfisher

class TweetTableViewCell: UITableViewCell {
    // MARK: -IBOutlets
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var nickLabel: UILabel!
    @IBOutlet weak var tweetLabel: UILabel!
    @IBOutlet weak var tweetImage: UIImageView!
    @IBOutlet weak var videoButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    //MARK: - Functions
    func setUpCellWith(post: Post){
        nameLabel.text = post.author.names
        nickLabel.text = post.author.nickname
        tweetLabel.text = post.text
        if post.hasImage {
            // Configuro imagenes
            tweetImage.kf.setImage(with: URL(string: post.imageUrl))
        }else{
            // Oculto la imagen
            tweetImage.isHidden = true
        }
    }
    
}

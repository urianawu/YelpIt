//
//  BusinessCell.swift
//  Yelp
//
//  Created by you wu on 2/8/16.
//  Copyright © 2016 Timothy Lee. All rights reserved.
//

import UIKit
import AFNetworking

class BusinessCell: UITableViewCell {

    @IBOutlet weak var thumbnailView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingView: UIImageView!
    @IBOutlet weak var reviewLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var business: Business! {
        didSet {
            nameLabel.text = business.name
            if business.imageURL != nil {
                thumbnailView.setImageWithURL(business.imageURL!)
            }
            distanceLabel.text = business.distance
            if business.ratingImageURL != nil {
            ratingView.setImageWithURL(business.ratingImageURL!)
            }
            reviewLabel.text = "\(business.reviewCount!) reviews"
            addressLabel.text = business.address
            categoryLabel.text = business.categories
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        thumbnailView.layer.cornerRadius = 4
        thumbnailView.clipsToBounds = true
        
        //nameLabel.preferredMaxLayoutWidth = nameLabel.frame.size.width
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

//
//  CollabTableViewCell.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 9/7/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class CollabTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var talentLabel: UILabel!
    @IBOutlet weak var headshot: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

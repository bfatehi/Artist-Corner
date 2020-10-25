//
//  ShowcaseTableViewCell.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 8/9/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class ShowcaseTableViewCell: UITableViewCell {

    //Mark: Properties
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var talentLabel: UILabel!
    @IBOutlet weak var postView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

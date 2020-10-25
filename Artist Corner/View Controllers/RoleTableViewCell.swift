//
//  RoleTableViewCell.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/25/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class RoleTableViewCell: UITableViewCell {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descLabel: UILabel!
    @IBOutlet weak var reqLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}

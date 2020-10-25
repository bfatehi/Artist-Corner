//
//  ProductDetailsVC.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class ProductDetailsVC: UIViewController {
    
    //Mark: Outlets
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var statusLabel: UILabel!
    @IBOutlet weak var projectDescription: UITextView!
    
    //Mark: Variables
    var project = Project()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        titleLabel.text = project.name
        statusLabel.text = project.status
        projectDescription.text = project.descript
        
        
        
        // Do any additional setup after loading the view.
    }

}

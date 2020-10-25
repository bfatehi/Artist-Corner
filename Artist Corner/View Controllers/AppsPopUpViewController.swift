//
//  AoosPopUpViewController.swift
//  Artist Corner
//
//  Created by Brahm Fatehi on 8/19/19.
//  Copyright © 2019 Artist Corner. All rights reserved.
//

import UIKit

class AppsPopUpViewController: UIViewController {
    
    var curRole = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        self.view.removeFromSuperview()
        //parent.viewDidLoad()
        if let parent = self.parent as? RolesVC2{
            parent.uploaded[curRole] = false
            parent.viewDidLoad()
        }else{
            fatalError("incorrect parent class")
        }
    }
    
}

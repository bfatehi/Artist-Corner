//
//  RoleDelegationViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/25/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class RoleDelegationViewController: UIViewController {
    
    @IBOutlet weak var roleText: UITextField!
    var UID = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if roleText.text != ""{
            if let parent = self.parent as? MemberAddViewController{
                parent.project.team.append((UID + ", " + roleText.text!))
                self.view.removeFromSuperview()
            } else {
                fatalError("incorrect parent")
            }
        }
    }

}

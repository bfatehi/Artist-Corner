//
//  RolePopUpViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/25/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class RolePopUpViewController: UIViewController {
    
    @IBOutlet weak var roleName: UITextField!
    @IBOutlet weak var roleDesc: UITextField!
    @IBOutlet weak var roleReq: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }
    
    @IBAction func donePressed(_ sender: Any) {
        if (roleName.text != "" && roleDesc.text != "" && roleReq.text != ""){
            if let parent = self.parent as? AddRolesViewController{
                if parent.project.reqRoles != ["none"]{
                    parent.project.reqRoles.append((roleName.text! + ", " + roleDesc.text! + ", " + roleReq.text!))
                    parent.project.apps.append("none")
                }else{
                    parent.project.reqRoles = [(roleName.text! + ", " + roleDesc.text! + ", " + roleReq.text!)]
                    parent.project.apps.append("none")
                }
                self.view.removeFromSuperview()
                parent.viewDidLoad()
            } else {
                fatalError("incorrect parent")
            }
        }
    }

}

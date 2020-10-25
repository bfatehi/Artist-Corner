//
//  RolesVC.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit

class RolesVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Variables
    var project = Project()
    var applicants = [String()]
    var projKey = String()
    var curProj = Int()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true

        tableView.delegate = self
        tableView.dataSource = self
        
        if self.project.reqRoles == ["none"]{
            self.tableView.allowsSelection = false
        }
        
        self.tableView.reloadData()
        
        
        
        print("roles: ", project.reqRoles)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if project.reqRoles.count != 0{
            return project.reqRoles.count
        }else{
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "RoleTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? RoleTableViewCell else{
            fatalError("The dequeued cell is not an instance of RoleTableViewCell.")
        }
        if project.reqRoles == [] || project.reqRoles == ["none"]{
            cell.nameLabel.text = "Not currently searching for talent."
            cell.descLabel.text = "Sorry!"
            cell.reqLabel.text = "Please check back later!"
        }else{
            cell.nameLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[0]
            cell.descLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[1]
            cell.reqLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[2]
        }
        
        
        return cell
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ToApps":
            guard let AppsController = segue.destination as? ApplicantsViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedRoleCell = sender as? RoleTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender)")
            }
            //print("sender is: ", sender)
            
            guard let indexPath = tableView.indexPath(for: selectedRoleCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //            print("indexPath is: ", indexPath)
            //            print("iterator is: ", indexPath.row)
            
            let selectedRole = project.reqRoles[indexPath.row]
            self.applicants = (project.apps[indexPath.row]?.components(separatedBy: ", "))!
            AppsController.applicants = self.applicants
            AppsController.project = self.project
            AppsController.curRole = indexPath.row
            AppsController.projKey = self.projKey
            AppsController.curProj = self.curProj
//            print("applicants list = ", applicants)
//            print(selectedRole)
            //            print("users: ", users)
            //            print("uid: ", users[indexPath.row].uid)
            //            print("selected prof: ", selectedProfile)
//            AppsController.userID = selectedRole!
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}

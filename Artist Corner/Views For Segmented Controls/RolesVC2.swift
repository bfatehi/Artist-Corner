//
//  RolesVC2.swift
//  Artist Corner
//
//  Created by Brahm Fatehi on 8/14/19.
//  Copyright © 2019 Artist Corner. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth

class RolesVC2: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    //Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Variables
    var project = Project()
    var ref = Database.database().reference()
    var projKey = String()
    var uploaded = [Bool()]
    var myApps = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        if self.project.reqRoles == ["none"]{
            self.tableView.allowsSelection = false
        }
        
        if uploaded.count != project.apps.count{
            for r in project.apps{
                uploaded.append(false)
            }
        }
        self.tableView.reloadData()
        
        
        
        print("roles: ", project.reqRoles)
        print("my apps list comes in with", self.myApps)
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
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(self.project.reqRoles)
        if self.project.reqRoles != ["none"]{
            self.apply(role: indexPath.row){
                if self.uploaded[indexPath.row]{
                    print("my apps should now be updated: ", self.myApps)
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "AppsPopUp") as! AppsPopUpViewController
                    popOverVC.curRole = indexPath.row
                    self.addChild(popOverVC)
                    popOverVC.view.frame = self.view.frame
                    self.view.addSubview(popOverVC.view)
                    popOverVC.didMove(toParent: self)
                    //self.uploaded[indexPath.row] = false
                }else{
                    print("my apps should now be updated: ", self.myApps)
                    let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Apps2PopUp") as! AppsPopUpViewController
                    self.addChild(popOverVC)
                    popOverVC.view.frame = self.view.frame
                    self.view.addSubview(popOverVC.view)
                    popOverVC.didMove(toParent: self)
                    //self.uploaded[indexPath.row] = false
                }
            }
        }else{
            let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "Apps3PopUp") as! AppsPopUpViewController
            self.addChild(popOverVC)
            popOverVC.view.frame = self.view.frame
            self.view.addSubview(popOverVC.view)
            popOverVC.didMove(toParent: self)
        }
    }
    
    func apply(role: Int, completion: @escaping () -> ()){
        print("apply called")
        let userID = Auth.auth().currentUser?.uid
        var list = project.apps[role]
        var appList = myApps
        print(self.project.apps)
        //project update
        if self.project.apps[role] == "none"{
            print("no applications for role")
            self.ref.child("projects2").child(self.projKey).child("apps").child(String(role)).setValue(userID!)
            if self.myApps == ""{
                self.myApps = projKey
                self.ref.child("users").child(userID!).child("apps").child("apps").setValue(self.myApps)
            }else if self.myApps.contains(projKey){
                print("have this in apps list already")
            }else{
                self.myApps = self.myApps + ", " + projKey
                self.ref.child("users").child(userID!).child("apps").child("apps").setValue(self.myApps)
            }
            self.project.apps[role] = userID
            self.uploaded[role] = true
            if let parent = self.navigationController?.children[0] as? JobsViewController{
                print("parent var equals jobs view")
                parent.myApps = myApps
            }else{
                fatalError("parent not reached")
            }
            completion()
            //self.ref.child("projects").child(self.project.ownerUID!).child("projects").child(self.project.num!).setValue(list)
        }else if !(self.project.apps[role]?.contains(userID!))!{
            list = list! + ", " + userID!
            print("role list should now be: ", list)
            self.ref.child("projects2").child(self.projKey).child("apps").child(String(role)).setValue(list)
            if self.myApps == ""{
                self.myApps = projKey
                self.ref.child("users").child(userID!).child("apps").child("apps").setValue(self.myApps)
            }else if self.myApps.contains(projKey){
                print("have this in apps list already")
            }else{
                self.myApps = self.myApps + ", " + projKey
                self.ref.child("users").child(userID!).child("apps").child("apps").setValue(self.myApps)
            }
            //self.ref.child("users").child(userID!).child("apps").child("apps").setValue(myApps + ", " + projKey)
            self.project.apps[role] = list
            self.uploaded[role] = true
            if let parent = self.navigationController?.children[0] as? JobsViewController{
                print("parent var equals jobs view")
                parent.myApps = myApps
            }else{
                fatalError("parent not reached")
            }
            completion()
        }else {
            print("already have this user's application")
            uploaded[role] = false
            //print(self.presentingViewController?.childViewControllers[3])
            //print(self.parent?.parent?.parent?.childViewControllers)
            if let parent = self.navigationController?.children[0] as? JobsViewController{
                print("parent var equals jobs view")
                parent.myApps = myApps
            }else{
                fatalError("parent not reached")
            }
            completion()
        }
    }
    
    
//    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        super.prepare(for: segue, sender: sender)
//        switch(segue.identifier ?? "") {
//        case "ToApps":
//            guard let AppsController = segue.destination as? ApplicantsViewController else {
//                fatalError("Unexpected destination: \(segue.destination)")
//            }
//
//            guard let selectedRoleCell = sender as? RoleTableViewCell
//                else {
//                    fatalError("Unexpected sender: \(sender)")
//            }
//            //print("sender is: ", sender)
//
//            guard let indexPath = tableView.indexPath(for: selectedRoleCell) else {
//                fatalError("The selected cell is not being displayed by the table")
//            }
//
//            //            print("indexPath is: ", indexPath)
//            //            print("iterator is: ", indexPath.row)
//
//            let selectedRole = project.reqRoles[indexPath.row]
//            print(selectedRole)
//            //            print("users: ", users)
//            //            print("uid: ", users[indexPath.row].uid)
//            //            print("selected prof: ", selectedProfile)
//        //            AppsController.userID = selectedRole!
//        default:
//            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
//        }
//    }
    
}

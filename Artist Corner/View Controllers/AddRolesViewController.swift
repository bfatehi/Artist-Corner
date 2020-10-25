//
//  AddRolesViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/25/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import Firebase

class AddRolesViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    //Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Variables
    var project = Project()
    var ref = Database.database().reference()
    var downloadURL = String()
    var projectCount = Int()
    var art = UIImage()
    var curProj = Int()
    var myProjs = String()
    var key = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
        self.tableView.allowsSelection = false
        self.tableView.reloadData()
        
        
        
        print("roles: ", project.reqRoles)
        // Do any additional setup after loading the view.
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
            cell.nameLabel.text = "Please click button on the bottom"
            cell.descLabel.text = "to add roles required"
        }else{
            cell.nameLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[0]
            cell.descLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[1]
            cell.reqLabel.text = project.reqRoles[indexPath.row]?.components(separatedBy: ", ")[2]
        }
                
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            project.reqRoles.remove(at: indexPath.row)
            project.apps.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            print("Need to add insert logic")
        }
    }
    
    func uploadArt(completion: @escaping () -> Void) {
        print("upload reached")
        self.fetchUserData {
            if let artData = self.art.jpegData(compressionQuality: 0.2){
                let artUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                self.key = self.ref.child("projects2").childByAutoId().key
                let storageRef = Storage.storage().reference().child(self.project.ownerUID!).child("projects").child(self.key)
                storageRef.putData(artData, metadata: metaData){
                    (metadata, error) in
                    if error != nil {print("something went wrong with headshot", error!)
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let downloadString = url else{
                            print(error)
                            return
                        }
                        self.downloadURL = downloadString.absoluteString
                        
                        print("art url retrieved")
                        completion()
                    }
                }
            }
        }
    }
    
    func editArt(completion: @escaping () -> Void) {
        print("upload reached")
        self.fetchUserData {
            if let artData = self.art.jpegData(compressionQuality: 0.2){
                let artUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                let storageRef = Storage.storage().reference().child(self.project.ownerUID!).child("projects").child(self.myProjs.components(separatedBy: ", ")[self.curProj - 1])
                storageRef.putData(artData, metadata: metaData){
                    (metadata, error) in
                    if error != nil {print("something went wrong with headshot", error!)
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let downloadString = url else{
                            print(error)
                            return
                        }
                        self.downloadURL = downloadString.absoluteString
                        
                        print("art url retrieved")
                        completion()
                    }
                }
            }
        }
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
        ref.child("users").child(self.project.ownerUID!).child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print("projects pull looks like:", value)
            if let temp = value?["projects"]{
                print("optional not nil")
                print("before iteratiion: ", self.myProjs)
                print("new key: ", temp)
                self.myProjs = temp as! String
                print("after iteration: ", self.myProjs)
                completion()
            }else{
                print("optional was nil")
            }
            
        }) { (error) in
            self.projectCount = 0
            completion()
            print(error.localizedDescription)
        }
    }
    
    func uploadProject(dict: [String:Any], completion: @escaping () -> Void) {
        ref.child("projects2").child(self.key).setValue(dict)
        if self.myProjs == ""{
            self.myProjs = self.key
        }else{
            self.myProjs =  self.myProjs + ", " + self.key
        }
        self.ref.child("users").child(project.ownerUID!).child("projects").setValue(["projects": self.myProjs])

        completion()
    }
    
    func editProject(dict: [String:Any], completion: @escaping () -> Void) {
        self.ref.child("projects2").child(self.myProjs.components(separatedBy: ", ")[self.curProj - 1]).setValue(dict)
        completion()
    }
    
    //Mark: Action Function
    @IBAction func backPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func addPressed(_ sender: UIButton) {
        let popOverVC = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "RolePopUp") as! RolePopUpViewController
        self.addChild(popOverVC)
        popOverVC.view.frame = self.view.frame
        self.view.addSubview(popOverVC.view)
        popOverVC.didMove(toParent: self)
    }
    
    @IBAction func finishPressed(_ sender: Any) {
        print("finish pressed")
        var dict = self.project.toDictionary()
        print(self.parent?.children[2])
        //Add art
        if let presenter = self.parent?.children[2] as? AddProjectViewController{
            self.uploadArt {
                print("finished upload of art")
                if self.project.reqRoles.count == 0{
                    dict["reqRoles"] = ["none"]
                    dict["apps"] = ["none"]
                }
                dict["art"] = self.downloadURL
                self.project.art = self.downloadURL
                self.fetchUserData {
                    self.uploadProject(dict: dict){
                        print("should be uploaded")
                        if let parentVC = self.parent?.children[1] as? MyProjectsViewController{
                                parentVC.projects.append(self.project)
                                parentVC.projKeys.append(self.key)
                                parentVC.projectCount = parentVC.projectCount+1
                                self.navigationController?.popToViewController(parentVC, animated: true)
                        }
                    }
                }
            }
        }else if let presenter = self.parent?.children[2] as? ProjectViewController{
            self.editArt {
                print("finished upload of art")
                dict["art"] = self.downloadURL
                self.project.art = self.downloadURL
                self.editProject(dict: dict){
                    if let parentVC = self.parent?.children[1] as? MyProjectsViewController{
                        self.navigationController?.popToViewController(parentVC, animated: true)
                    }
                }
            }
        }
        
        
    }
    
}

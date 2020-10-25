//
//  JobsViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import Firebase

class JobsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate {
  
    
    
    //Mark: outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Variables
    var allProjects = [Project()]
    var apps = [Project()]
    var selectedSegment = 1
    var userID = ""
    var ref = Database.database().reference()
    var projKeys = [String()]
    var firstLoad = true
    var myApps = String()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.searchBar.delegate = self
        self.tableView.dataSource = self
        
        self.userID = (Auth.auth().currentUser?.uid)!
        
        self.downloadApps {
            self.downloadProjects(){
                print("view did load download complete")
                self.firstLoad = false
                self.tableView.reloadData()
            }
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        if !firstLoad{
            tableView.reloadData()
            self.downloadProjects {
                print("view will appear download complete")
                self.tableView.reloadData()
            }
        }
    }
    
    func downloadApps(completion: @escaping () -> Void){
        print("download myapps reached")
        ref.child("users").child(self.userID).child("apps").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            //print("my apps pull value obtained: ", value)
            self.myApps = value?["apps"] as? String ?? ""
            print("my apps should be update as: ", self.myApps)
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func downloadProjects(completion: @escaping () -> Void) {
        print("pull projects func reached")
        self.allProjects = []
        self.apps = []
        self.projKeys = []
        ref.child("projects2/"/* + userID + "/projects"*/).observe(.value){ snapshot in
            
            for child in snapshot.children {
                //print(child)
                let snap = child as? DataSnapshot
                let dictionary = snap?.value as! [String:Any]
                if let key = snap?.key {
                    self.projKeys.append(key)
                    let project = Project()
                    project.ownerUID = dictionary["ownerUID"] as! String
                    project.name = dictionary["name"] as! String
                    project.status = dictionary["status"] as! String
                    project.descript = dictionary["descript"] as! String
                    project.art = dictionary["art"] as! String
                    project.team = dictionary["team"] as! [String]
                    project.reqRoles = dictionary["reqRoles"] as! [String]
                    project.apps = dictionary["apps"] as! [String]
                    self.allProjects.append(project)
                    if self.myApps.contains(key){
                        self.apps.append(project)
                    }
                }else{
                    fatalError("could not autogenerate project key")
                }
            }
            completion()
        }
    }
    
    func downloadImageHeadShot(url: URL, imageView: UIImageView) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
                imageView.maskCircle(anyImage: imageView.image!)
            }
        }
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if selectedSegment == 1{
            return allProjects.count
        }else {
            return apps.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ProjectCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProjectTableViewCell else{
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        if selectedSegment == 1 {
            cell.nameLabel.text = allProjects[indexPath.row].name
            cell.descLabel.text = allProjects[indexPath.row].descript
            if allProjects[indexPath.row].art != nil {
                downloadImageHeadShot(url: NSURL(string: allProjects[indexPath.row].art!) as! URL, imageView: cell.art)
            }else{
                cell.art.image = #imageLiteral(resourceName: "noImageSelected")
            }
        }else{
            cell.nameLabel.text = apps[indexPath.row].name
            cell.descLabel.text = apps[indexPath.row].descript
            if apps[indexPath.row].art != nil {
                downloadImageHeadShot(url: NSURL(string: apps[indexPath.row].art!) as! URL, imageView: cell.art)
            }else{
                cell.art.image = #imageLiteral(resourceName: "noImageSelected")
            }
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "toProject":
            guard let ProjectController = segue.destination as? OffersViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProjectCell = sender as? ProjectTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender)")
            }
            //print("sender is: ", sender)
            
            guard let indexPath = tableView.indexPath(for: selectedProjectCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //            print("indexPath is: ", indexPath)
            //            print("iterator is: ", indexPath.row)
            
            if selectedSegment == 1{
                print("project name should be: ", allProjects[indexPath.row].name)
                let selectedProject = allProjects[indexPath.row]
                ProjectController.projKey = self.projKeys[indexPath.row]
                ProjectController.curProj = indexPath.row+1
                ProjectController.project = selectedProject
                ProjectController.myApps = self.myApps
            }else{
                print("project name should be: ", apps[indexPath.row].name)
                let selectedProject = apps[indexPath.row]
                ProjectController.projKey = self.projKeys[indexPath.row]
                ProjectController.curProj = indexPath.row+1
                ProjectController.project = selectedProject
                ProjectController.myApps = self.myApps
            }
            
        case "MyProjects":
            self.allProjects = []
            self.apps = []
            self.projKeys = []
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //Mark: Actions
    @IBAction func toggle(_ sender: UISegmentedControl) {
        if sender.selectedSegmentIndex == 0{
            selectedSegment = 1
        }else{
            selectedSegment = 2
        }
        self.tableView.reloadData()
        print("toggle is now at: ", selectedSegment)
    }
    
    
    
}

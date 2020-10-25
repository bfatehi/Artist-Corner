//
//  MyProjectsViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import Firebase

class MyProjectsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    //Mark: Variables
    @IBOutlet weak var tableView: UITableView!
    var ref = Database.database().reference()
    var userID = String()
    var projectCount = Int()
    var projects = [Project()]
    var updatedContent = Bool()
    var projs = [String()]
    var projKeys = [String()]
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        print("view did load")
        tableView.dataSource = self
        tableView.delegate = self
        
        self.userID = (Auth.auth().currentUser?.uid)!
        print("project count is", projectCount)
        if projects.count == 1{
            print("project count = 1")
            self.fetchUserData {
                self.fetchProjects {
                    print("projects array count: ", self.projects.count)
                    self.projectCount = self.projects.count - 1
                    if self.projectCount == 0{
                        self.tableView.allowsSelection = false
                    }
                    self.tableView.reloadData()
                }
           }
        }else {
            print("else statement reload")
            self.tableView.reloadData()
        }
    }
    
    override func viewWillAppear(_ animated:Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
        print("fetch user func reached")
        ref.child("users").child(self.userID).child("projects").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            print("value: ", value)
            if let list = value?["projects"] as? String{
                print("optional isnt nil")
                self.projs = list.components(separatedBy: ", ")
                //print("projs array looks like: ", self.projs)
                if list != ""{
                    self.projectCount = self.projs.count
                }
            }else{
                print("no value in optional")
                self.projectCount = 0
            }
            print("project count: ", self.projectCount)
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func fetchProjects(completion: @escaping () -> Void){
        print("fetch projects func reached")
        if self.projectCount != 0{
            for p in projs{
                ref.child("projects2").child(p).observeSingleEvent(of: .value, with: { (snapshot) in
                self.projKeys.append(snapshot.key)
                let dictionary = snapshot.value as! [String: Any]
                let project = Project()
                project.ownerUID = dictionary["ownerUID"] as! String
                project.name = dictionary["name"] as! String
                project.status = dictionary["status"] as! String
                project.descript = dictionary["descript"] as! String
                project.art = dictionary["art"] as! String
                project.team = dictionary["team"] as! [String]
                project.reqRoles = dictionary["reqRoles"] as! [String]
                project.apps = dictionary["apps"] as! [String]
                self.projects.append(project)

                
                completion()
                })
            }
        }else{
            print("fetch reached but no projects")
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
        if self.projects.count != 1{
            return self.projectCount
        } else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "ProjectCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? ProjectTableViewCell else{
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let project : Project
        if self.projects.count != 1{
            print("project logic")
            print("index: ", indexPath.row)
            print("name: ", self.projects[indexPath.row].name)
            print(self.projects[0])
            project = self.projects[indexPath.row+1]
            downloadImageHeadShot(url: NSURL(string: project.art!) as! URL, imageView: cell.art)
            cell.nameLabel.text = project.name
            cell.descLabel.text = project.descript
        }else {
            cell.art.image = #imageLiteral(resourceName: "noImageSelected")
            cell.nameLabel.text = "No projects yet! Please"
            cell.descLabel.text = "hit + button at top right!"
        }
        
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "toProject":
            guard let ProjectController = segue.destination as? ProjectViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }

            guard let selectedProjectCell = sender as? ProjectTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender)")
            }

            guard let indexPath = tableView.indexPath(for: selectedProjectCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            print("project name should be: ", projects[indexPath.row+1].name)
            let selectedProject = projects[indexPath.row+1]
            ProjectController.curProj = indexPath.row+1
            ProjectController.projKey = self.projKeys[indexPath.row+1]
            ProjectController.project = selectedProject
        
        case "add":
            break
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //Mark: Action Functions
    @IBAction func backPressed(_ sender: Any) {
        print(self.presentingViewController?.children)
        if let presenter = self.navigationController?.children[0] as? JobsViewController{
            print("prep for return to jobs page should be complete")
            presenter.allProjects = []
            presenter.apps = []
            presenter.projKeys = []
            self.projs = []
            self.projects = []
            self.projectCount = 0

            self.navigationController?.popToViewController(presenter, animated: true)

        }else{
            print("error")
        }
    }
    
    
}

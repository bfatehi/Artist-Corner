//
//  TeamAddViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/18/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase

class TeamAddViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    //Mark: Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mark: Variables
    var project = Project()
    var users = [User]()
    var ref = Database.database().reference()
    var updatedUsers = false
    var firstPost = Bool()
    var roles = [String()]
    var art = UIImage()
    var curProj = Int()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        print("uid: ", project.ownerUID, "name: ", project.name, "status: ", project.status,  "desc: ", project.descript, "team", project.team)
        
        if project.team == []{
            print("no fetch")
            self.tableView.allowsSelection = false
            self.tableView.reloadData()
        }else{
            print("we have users")
            self.roles.removeAll()
            fetchUsers(){
                print(self.users.count)
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if updatedUsers{
            self.loadNewMembers()        }
    }
    
    func loadNewMembers() {
        let temp = self.users
        self.users.removeAll()
        self.roles.removeAll()
        fetchUsers(){
            print(self.users.count)
            self.tableView.reloadData()
        }
    }
    
    func fetchUsers(completion: @escaping () -> Void){
        for u in project.team{
            let userID = u?.components(separatedBy: ", ")[0]
            self.roles.append((u?.components(separatedBy: ", ")[1])!)
            ref.child("users").child(userID!).observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value {
                    let uid = userID
                    let first = snapshot.childSnapshot(forPath: "first").value as? NSDictionary
                    let last = snapshot.childSnapshot(forPath: "last").value as? NSDictionary
                    let talent = snapshot.childSnapshot(forPath: "talent").value as? NSDictionary
                    let headShot = snapshot.childSnapshot(forPath: "headShot").value as? NSDictionary
                    let DOB = snapshot.childSnapshot(forPath: "DOB").value as? NSDictionary
                    let contact = snapshot.childSnapshot(forPath: "contact").value as? NSDictionary
                    let gender = snapshot.childSnapshot(forPath: "gender").value as? NSDictionary
                    let location = snapshot.childSnapshot(forPath: "location").value as? NSDictionary
                    let username = snapshot.childSnapshot(forPath: "username").value as? NSDictionary
                    let user = User()
                    user.uid = uid
                    user.first = first?["first"] as? String
                    user.last = last?["last"] as? String
                    user.talent = talent?["talent"] as? String
                    user.headShot = headShot?["headShotURL"] as? String
                    user.DOB = DOB?["DOB"] as? String
                    user.contact = contact?["contact"] as? String
                    user.gender = gender?["gender"] as? String
                    user.location = location?["location"] as? String
                    user.username = username?["username"] as? String
                    self.users.append(user)
                    print(user.first)
                    if self.project.team.count == self.users.count{
                        completion()
                    }
                }else {
                    print("dictionary not created")
                    completion()
                }
            })
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
    
    ///Table Functions
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if project.team.count != 0{
            return project.team.count
        }else {
            return 1
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellIdentifier = "TeamTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? TeamTableViewCell else{
            fatalError("The dequeued cell is not an instance of TeamTableViewCell.")
        }
        
        if self.users == []{
            print("no users update logic reached")
            cell.nameLabel.text = "Please click button on the bottom"
            cell.talentLabel.text = "to add users to team"
            cell.roleLabel.text = ""
            cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
            firstPost = true
        }else{
            let user : User
            print("user list: ", self.users)
            user = self.users[indexPath.row]
            cell.nameLabel.text = user.first! + " " + user.last!
            cell.talentLabel.text = user.talent!
            cell.roleLabel.text = roles[indexPath.row]
            if user.headShot != nil{
                downloadImageHeadShot(url: NSURL(string: user.headShot!) as! URL, imageView: cell.headshot)
            } else {
                cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            users.remove(at: indexPath.row)
            roles.remove(at: indexPath.row)
            project.team.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .fade)
            tableView.endUpdates()
        } else if editingStyle == .insert {
            print("Need to add insert logic")
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "AddRoles":
            guard let AddRolesController = segue.destination as? AddRolesViewController
                else{
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            
            AddRolesController.project = self.project
            AddRolesController.art = self.art
            AddRolesController.curProj = self.curProj
        case "MemberAdditions":
            guard let MemberAddController = segue.destination as? MemberAddViewController
                else{
                    fatalError()
                }
            MemberAddController.project = self.project
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //Mark: Action Function
    @IBAction func addTeam(_ sender: Any) {
        performSegue(withIdentifier: "MemberAdditions", sender: sender)
    }
    
    @IBAction func nextPressed(_ sender: Any) {
        print("next pressed")
    }
    
    @IBAction func cancelPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    

}

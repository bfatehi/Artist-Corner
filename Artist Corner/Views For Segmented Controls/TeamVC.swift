//
//  TeamVC.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase

class TeamVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    
    
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
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tabBarController?.tabBar.isHidden = true
        self.tableView.dataSource = self
        self.tableView.delegate = self
        
        print("team tab viewdidload")
        
        if project.team == []{
            print("no fetch")
            
            self.tableView.allowsSelection = false
            self.tableView.reloadData()
        }else{
            fetchUsers(){
                print(self.users.count, " team members after fetch")
                self.tableView.reloadData()
            }
        }
        
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if updatedUsers{
            self.loadNewMembers()
        }
    }
    
    func loadNewMembers() {
        print("load members func reached")
        self.viewDidLoad()
                if firstPost {
                    print("reaching first post in loadPost")
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    tableView.insertRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    tableView.endUpdates()
                    self.firstPost = false
                }else{
                    tableView.beginUpdates()
                    tableView.insertRows(at: [IndexPath(row: project.team.count, section: 0)], with: .automatic)
                    tableView.endUpdates()
                }
    }
    
    func fetchUsers(completion: @escaping () -> Void){
        for u in project.team{
            let userID = u?.components(separatedBy: ", ")[0]
            self.roles.append((u?.components(separatedBy: ", ")[1])!)
            ref.child("users").child(userID!).observe(.value, with: { (snapshot) in
                
                if let dictionary = snapshot.value {
                    //print(dictionary)
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
                    //                    //input other necessary valurs here
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
                    //self.tableView.reloadData()
                    if self.project.team.count == self.users.count{
                        completion()
                    }
                }else {
                    print("dictionary not created")
                    completion()
                }
            })
        }
        //print("no users")
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
        
       // if project.team == []{
         if self.users.count == 0{
            cell.nameLabel.text = "Please click button on the bottom"
            cell.talentLabel.text = "to add users to team"
            cell.roleLabel.text = ""
            cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
            firstPost = true
        }else{
            let user : User
            print(self.users)
            //print("there are ", self.users.count, " number of users in the project")
            user = self.users[indexPath.row]
            cell.nameLabel.text = user.first! + " " + user.last!
            cell.talentLabel.text = user.talent!
            cell.roleLabel.text = roles[indexPath.row+1]
            if user.headShot != nil{
                downloadImageHeadShot(url: NSURL(string: user.headShot!) as! URL, imageView: cell.headshot)
            } else {
                cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
            }
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ToUser":
            guard let UserProfileController = segue.destination.children[0] as? PortfolioViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProfileCell = sender as? TeamTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender)")
            }
            //print("sender is: ", sender)
            
            guard let indexPath = tableView.indexPath(for: selectedProfileCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
            //            print("indexPath is: ", indexPath)
            //            print("iterator is: ", indexPath.row)
            
            let selectedProfile = users[indexPath.row].uid
            //            print("users: ", users)
            //            print("uid: ", users[indexPath.row].uid)
            //            print("selected prof: ", selectedProfile)
            UserProfileController.userID = selectedProfile!
            UserProfileController.user = users[indexPath.row]
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }

}

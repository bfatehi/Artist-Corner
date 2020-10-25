//
//  CollabViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 5/24/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import FirebaseStorage
import FirebaseAnalytics
import FirebaseDatabase
import FBSDKCoreKit
import FBSDKLoginKit
import os.log

class CollabViewController: UIViewController, UISearchBarDelegate, UITableViewDelegate, UITableViewDataSource/*, UINavigationControllerDelegate*/ {
    
    //Mark: Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var searchTable: UITableView!
    
    //Mark: Variables
    var ref = Database.database().reference()
    var name = [String()]
    var talent = [String()]
    var head = [UIImage()]
    var users = [User]()
    var filtered = [User]()
    var searchBarActive = Bool()
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchBar.delegate = self
        self.searchTable.delegate = self
        self.searchTable.dataSource = self
        
        fetchUsers(){
            self.searchTable.reloadData()
        }
        
    }
    
    func fetchUsers(completion: @escaping () -> Void){
        ref.child("users//").observe(.childAdded, with: { (snapshot) in
            
            if let dictionary = snapshot.value {
                let uid = snapshot.key
                let first = snapshot.childSnapshot(forPath: "first").value as? NSDictionary
                let last = snapshot.childSnapshot(forPath: "last").value as? NSDictionary
                let talent = snapshot.childSnapshot(forPath: "talent").value as? NSDictionary
                let headShot = snapshot.childSnapshot(forPath: "headShot").value as? NSDictionary
                let DOB = snapshot.childSnapshot(forPath: "DOB").value as? NSDictionary
                let contact = snapshot.childSnapshot(forPath: "contact").value as? NSDictionary
                let gender = snapshot.childSnapshot(forPath: "gender").value as? NSDictionary
                let location = snapshot.childSnapshot(forPath: "location").value as? NSDictionary
                let username = snapshot.childSnapshot(forPath: "username").value as? NSDictionary
                //input other necessary valurs here
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
                self.searchTable.reloadData()
                completion()
            }else {
                print("dictionary not created")
            }
        })
        
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
    
    
    //Mark: Tableview Functionality
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if  searchBarActive && searchBar.text != ""{
            return filtered.count
        }else {
            return users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "CollabTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as? CollabTableViewCell else{
            fatalError("The dequeued cell is not an instance of MealTableViewCell.")
        }
        
        let user : User
        
        if  searchBarActive && searchBar.text != ""{
            user = self.filtered[indexPath.row]
        }else{
            user = self.users[indexPath.row]
        }
//        cell.nameLabel.text = "test"
//        cell.talentLabel.text = "coding"
//        cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
        
        cell.nameLabel.text = user.first! + " " + user.last!
        cell.talentLabel.text = user.talent
        
        if user.headShot != nil{
            downloadImageHeadShot(url: NSURL(string: user.headShot!) as! URL, imageView: cell.headshot)
        } else {
            cell.headshot.image = #imageLiteral(resourceName: "noImageSelected")
        }
        
        return cell
    }
    
//    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//
//        performSegue(withIdentifier: "ToUser", sender: nil)
//    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch(segue.identifier ?? "") {
        case "ToUser":
            guard let UserProfileController = segue.destination as? PortfolioViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let selectedProfileCell = sender as? CollabTableViewCell
                else {
                    fatalError("Unexpected sender: \(sender)")
            }
            //print("sender is: ", sender)
            
            guard let indexPath = searchTable.indexPath(for: selectedProfileCell) else {
                fatalError("The selected cell is not being displayed by the table")
            }
            
//            print("indexPath is: ", indexPath)
//            print("iterator is: ", indexPath.row)
            
            let selectedProfile = users[indexPath.row].uid
//            print("users: ", users)
//            print("uid: ", users[indexPath.row].uid)
//            print("selected prof: ", selectedProfile)
            UserProfileController.userID = selectedProfile!
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    
    //Mark: search bar functionality
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchBarActive = true
        filterUsers(searchText: searchText)
    }
    
    func filterUsers(searchText: String){
        
        self.filtered = self.users.filter{ user in
            
            let first  = user.first
            let last = user.last
            let talent = user.talent
            return ((first?.lowercased().contains(searchText.lowercased()))!
                || (last?.lowercased().contains(searchText.lowercased()))! || (talent?.lowercased().contains(searchText.lowercased()))!)
            
        }
        self.searchTable.reloadData()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
    }
    
}
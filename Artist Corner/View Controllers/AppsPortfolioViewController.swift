//
//  AppsPortfolioViewController.swift
//  Artist Corner
//
//  Created by Brahm Fatehi on 8/21/19.
//  Copyright © 2019 Artist Corner. All rights reserved.
//

import UIKit
import Foundation
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import AVKit
import AVFoundation

class AppsPortfolioViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    //Mark: Outlets
    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var talentLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    @IBOutlet weak var postsTable: UITableView!
    
    
    
    //Mark: Variables
    var ref = Database.database().reference()
    var first = String()
    var last = String()
    var talent = String()
    var location = String()
    var contact = String()
    var numPosts = Int()
    var postInfoArray = [String()]
    var newImage = UIImage()
    var newPost = Bool()
    var firstPost = Bool()
    var userID = String()
    var project = Project()
    var user = User()
    var curRole = Int()
    var projKey = String()
    var curProj = Int()
    var startFrame: CGRect?
    var backdrop: UIView?
    var startingImgView = UIImageView()
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        self.postsTable.delegate = self
        self.postsTable.dataSource = self
        
        self.headShotSetup()
        self.labelSetups(){
            self.fetchUserData(){
                self.postArraySetupIterator(numPosts: self.numPosts){
                    if self.numPosts == 0{
                        self.postsTable.allowsSelection = false
                    }
                    self.postsTable.reloadData()
                }
            }
        }
    }
    
    
    //to prevent scrolling horizontally
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
        //let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID).child("posts").child("numberPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.numPosts = Int(value?["number"] as? String ?? "")!
            //print(self.numPosts)
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func headShotSetup() {
        //let userID = Auth.auth().currentUser?.uid
        ref.child("users").child(userID).child("headShot").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let headShotURL = value?["headShotURL"] as? String ?? ""
            let url:NSURL = NSURL(string: headShotURL)!
            //if value isn't nil download image for use
            if value != nil{
                self.downloadImageHeadShot(url: url as URL, imageView: self.headShot)
            } //if value is nil, use placeholder image
            else {
                self.headShot.image = #imageLiteral(resourceName: "noImageSelected")
                self.headShot.maskCircle(anyImage: self.headShot.image!)
            }
        }) { (error) in
            print(error.localizedDescription)
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
    
    func labelSetups(completion: @escaping () -> Void) {
        self.talent = self.user.talent!
        self.first = self.user.first!
        self.last = self.user.last!
        self.contact = self.user.contact!
        self.location = self.user.location!
        self.nameLabel.text = self.first + " " + self.last
        self.talentLabel.text = self.user.talent
        self.locationLabel.text = self.location
        self.contactLabel.text = self.contact
        completion()
    }
    
    func getDataFromUrl(url: URL, completion: @escaping (Data?, URLResponse?, Error?) -> ()) {
        URLSession.shared.dataTask(with: url) { data, response, error in
            completion(data, response, error)
            }.resume()
    }
    
    
    // MARK: - Table view data source
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if postInfoArray != [""]{
            return postInfoArray.count
        }else {
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "PortfolioTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as?
            PortfolioTableViewCell else{
                fatalError("The dequeued cell is not an instance of PortfolioTableViewCell.")
        }
        
        // Fetches the appropriate post for the data source layout.
        let tempArray = self.postInfoArray[indexPath.row].components(separatedBy: ", ")
        cell.descriptionLabel.text = tempArray[0]
        cell.talentLabel.text = tempArray[1]
        if tempArray.count == 4{
            downloadImage(url: NSURL(string: tempArray[3]) as! URL, imageView: cell.postView)
        }else if tempArray.count == 3{
            downloadImage(url: NSURL(string: tempArray[2]) as! URL, imageView: cell.postView)
        }else if tempArray[1] != "No Post Added Yet" {
            cell.postView.image = newImage
        }else{
            cell.postView.image = #imageLiteral(resourceName: "noImageSelected")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print(postInfoArray[indexPath.row])
        //ADD Code to make pic or vid display
        if postInfoArray[indexPath.row].components(separatedBy: ", ").count == 3{
            let cell = self.postsTable.cellForRow(at: indexPath) as? PortfolioTableViewCell
            if let start = (cell?.postView){
                self.zoomIn(startView: start)
            }
        }else{
            playBack(row: indexPath.row)
        }
    }
    
    func playBack(row: Int){
        if postInfoArray[row].components(separatedBy: ", ").count == 4{
            //display vid
            let url = NSURL(string: postInfoArray[row].components(separatedBy: ", ")[2])
            let player = AVPlayer(url: url as! URL)
            let playerViewController = AVPlayerViewController()
            playerViewController.player = player
            self.present(playerViewController, animated: true) {
                //***USE below if want to make it play immediately
                //playerViewController.player!.play()
            }
            
            print("attempting to create avplayer")
        }else{
            print("attempting to display pic in playback logic")
        }
    }
    
    func zoomIn(startView: UIImageView){
        print("attempting to zoom in")
        let size = startView.image?.size
        self.startingImgView = startView
        self.startingImgView.isHidden = true
        startFrame = startView.superview?.convert(startView.frame, to: nil)
        
        let zoomView = UIImageView(frame: startFrame!)
        zoomView.image = startView.image
        zoomView.isUserInteractionEnabled = true
        zoomView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(zoomOut)))
        
        if let keyWindow = UIApplication.shared.keyWindow{
            backdrop = UIView(frame: keyWindow.frame)
            backdrop?.backgroundColor = UIColor.black
            backdrop?.alpha = 0
            keyWindow.addSubview(backdrop!)
            
            keyWindow.addSubview(zoomView)
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backdrop?.alpha = 1
                let height = size!.height / size!.width * keyWindow.frame.width
                if height < keyWindow.frame.height{
                    zoomView.frame = CGRect(x: 0, y: 0, width: keyWindow.frame.width, height: height)
                    zoomView.center = keyWindow.center
                }else{
                    let width = size!.width / size!.height * keyWindow.frame.height
                    zoomView.frame = CGRect(x: 0, y: 0, width: width, height: keyWindow.frame.height)
                    zoomView.center = keyWindow.center
                }
            }, completion: nil)
        }
    }
    
    @objc func zoomOut(tapGesture: UITapGestureRecognizer){
        if let zoomView = tapGesture.view{
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
                self.backdrop?.alpha = 0
                zoomView.frame = self.startFrame!
            }, completion: { (completed: Bool) in
                zoomView.removeFromSuperview()
                self.startingImgView.isHidden = false
            })
        }
    }
    
    func postArraySetupIterator(numPosts: Int, completion: @escaping () -> Void){
        if numPosts == 0 {
            self.postInfoArray[0] = ("Click the + button in the top right of the screen to add your first post!, No Post Added Yet")
            completion()
        }else{
            var i = 0
            for n in self.postInfoArray.count...numPosts{
                self.postInfoArraySetup(numberOfPost: n){
                    i = i+1
                    if i == (numPosts) {
                        completion()
                    }
                }
            }
        }
    }
    
    func postInfoArraySetup(numberOfPost: Int, completion: @escaping () -> Void) {
        //let userID = Auth.auth().currentUser?.uid
        let currentPost = String(numberOfPost)
        ref.child("users").child(userID).child("posts").child(currentPost).observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            if self.postInfoArray[0] == ""{
                self.postInfoArray[0] = value?["postInfo"] as? String ?? ""
                print(self.postInfoArray)
                completion()
            }else{
                self.postInfoArray.append(value?["postInfo"] as? String ?? "")
                print(self.postInfoArray)
                completion()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
                print("downloading post thumb")
            }
        }
        
    }
    
    func editProject(dict: [String:Any], completion: @escaping () -> Void) {
        print("dict to be uploaded replacing old project data",dict)
        self.ref.child("projects2").child(projKey).setValue(dict)
        //self.ref.child("users").child(userID)
        completion()
    }
    
    func editUserApps(completion: @escaping () -> Void){
        //need to edit the string so if the value is at the front middle or end of the list it will adjust accordingly (also if there is a single value to replace with proper value)
        var temp = self.user.apps?.components(separatedBy: ", ")
        var edited = false
        if temp?.count == 1 && temp![0] == self.projKey{
            self.user.apps = "" //maybe use "none"
            edited = true
        }else{
            for a in temp!{
                if a == temp![0] && a == self.projKey{
                    self.user.apps?.replacingOccurrences(of: (self.projKey + ", "), with: "")
                    edited = true
                    print("user apps is now: ", self.user.apps)
                    break
                }else if a == self.projKey{
                    self.user.apps?.replacingOccurrences(of: (", " + self.projKey), with: "")
                    edited = true
                    print("user apps is now: ", self.user.apps)
                    break
                }else{
                    print("current iteration not equal to projKey")
                }
            }
            
        }
        if edited{
            print("this will be uploaded for user apps", self.user.apps)
            self.ref.child("users").child(userID).child("apps").child("apps").setValue(self.user.apps)
            completion()
        }else{
            print("edited logic not reached")
        }
    }
    
    @IBAction func headShotPressed(_ sender: UITapGestureRecognizer) {
        //Setup image enlargement
        zoomIn(startView: headShot)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        self.project.team.append(userID + ", " + ((self.project.reqRoles[curRole]?.components(separatedBy: ", ")[1])!))
        //self.project.apps.remove(at: curRole)
        if self.project.apps.count > 1{
            self.project.apps.remove(at: curRole)
        }else{
            self.project.apps = ["none"]
        }
        if self.project.reqRoles.count > 1{
            self.project.reqRoles.remove(at: curRole)
        }else{
            self.project.reqRoles = ["none"]
        }
        var dict = self.project.toDictionary()
        dict["art"] = self.project.art

        
        print("apps, team, roles after edit:")
        self.editProject(dict: dict){
            print("project should be updated")
            self.editUserApps(){
                print("user apps should be updated")
                if let presenter = self.navigationController?.children[1] as? MyProjectsViewController{
                    presenter.projects[self.curProj] = self.project
                    self.navigationController?.popToViewController(presenter, animated: true)
                }
            }
        }
    }
}

//
//  ShowcaseViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 5/22/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import Foundation
import UIKit
import SwiftKeychainWrapper
import Firebase
import FirebaseAuth
import FBSDKCoreKit
import FBSDKLoginKit
import AVFoundation
import AVKit

class ShowcaseViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    
    //Mark: Outlets
    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var talentLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var contactLabel: UILabel!
    //@IBOutlet weak var scrollView: UIScrollView!
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
    var startFrame: CGRect?
    var backdrop: UIView?
    var user = User()
    var startingImgView = UIImageView()

    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        userID = (Auth.auth().currentUser?.uid)!
        if(newPost){
        }else{
        print("viewdidload else reached")
        
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
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if(newPost){
            if !self.postsTable.allowsSelection{
                self.postsTable.allowsSelection = true
            }
            self.loadNewPost()
        }
    }
    
    
    //to prevent scrolling horizontally
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
    
    func loadNewPost() {
    }
    
    func fetchUserData(completion: @escaping () -> Void) {
       print("showcaseviewcontroller fetch user data func reached")
        ref.child("users").child(self.userID).child("posts").child("numberPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            self.numPosts = Int(value?["number"] as? String ?? "")!
            completion()
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func headShotSetup() {
        ref.child("users").child(self.userID).child("headShot").observeSingleEvent(of: .value, with: { (snapshot) in
            let value = snapshot.value as? NSDictionary
            let headShotURL = value?["headShotURL"] as? String ?? ""
            let url:NSURL = NSURL(string: headShotURL)!
            //if value isn't nil download image for use
            if value != nil{
                self.downloadImageHeadShot(url: url as URL, imageView: self.headShot)
            }
            //if value is nil, use placeholder image
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
        ref.child("users/" + self.userID).observe(.value, with: { (snapshot) in
            
            if let dictionary = snapshot.value {
                let uid = snapshot.key
                print("uid: ", uid)
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
                self.user = user
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
            }else {
                print("dictionary not created")
            }
        })
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
        let cellIdentifier = "ShowcaseTableViewCell"
        
        guard let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as?
            ShowcaseTableViewCell else{
            fatalError("The dequeued cell is not an instance of ShowcaseTableViewCell.")
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
            let cell = self.postsTable.cellForRow(at: indexPath) as? ShowcaseTableViewCell
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
            for n in 1...numPosts{
                self.postInfoArraySetup(numberOfPost: n){
                    i = i+1
                    if i == (numPosts) {
                        completion()
                    }
                }
            }
        }
    }
    
    func postInfoArraySetup(numberOfPost: Int, completion: @escaping () -> Void) {        let currentPost = String(numberOfPost)
        if self.postInfoArray.count != numPosts{
            ref.child("users").child(self.userID).child("posts").child(currentPost).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if self.postInfoArray[0] == ""{
                    self.postInfoArray[0] = value?["postInfo"] as? String ?? ""
                    completion()
                }else{
                    self.postInfoArray.append(value?["postInfo"] as? String ?? "")
                    completion()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }else if self.postInfoArray.count == 1{
            ref.child("users").child(self.userID).child("posts").child(currentPost).observeSingleEvent(of: .value, with: { (snapshot) in
                let value = snapshot.value as? NSDictionary
                if self.postInfoArray[0] == ""{
                    self.postInfoArray[0] = value?["postInfo"] as? String ?? ""
                    completion()
                }
                else{
                    //self.postInfoArray.append(value?["postInfo"] as? String ?? "")
                    completion()
                }
            }) { (error) in
                print(error.localizedDescription)
            }
        }else{
            completion()
        }
    }
    
    func downloadImage(url: URL, imageView: UIImageView) {
        getDataFromUrl(url: url) { data, response, error in
            guard let data = data, error == nil else { return }
            DispatchQueue.main.async() {
                imageView.image = UIImage(data: data)
//              imageView.maskCircle(anyImage: imageView.image!)
            }
        }
    }
    
    
    //Mark - headshot image picker controls
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        headShot.image = selectedImage
        
        
        //Add headshot
        if let headshotData = self.headShot.image!.jpegData(compressionQuality: 0.2){
            let headShotUID = NSUUID().uuidString
            let metaData = StorageMetadata()
            let storageRef = Storage.storage().reference().child(self.userID).child("headShot")
            storageRef.putData(headshotData, metadata: metaData){
                (metadata, error) in
                if error != nil {print("something went wrong with headshot", error!)
                    return
                }
                storageRef.downloadURL { (url, error) in
                    guard let downloadString = url else{
                        print(error)
                        return
                    }
                    let downloadURL = downloadString.absoluteString
                    self.ref.child("users").child(self.userID).child("headShot").setValue(["headShotURL": downloadURL])
                }
            }
        }
        dismiss(animated: true, completion: nil)
    }
    
    //Mark: Action Functions
    @IBAction func signOutPressed(_ sender: Any) {
        //need to logout of fb if logged in
        if KeychainWrapper.standard.hasValue(forKey: "KEY_UID_FB"){
            let loginManager = FBSDKLoginManager()
            loginManager.logOut()
            let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "KEY_UID_FB")
            performSegue(withIdentifier: "toStart", sender: nil)
            print("Key removal happened:", removeSuccessful)
        }//need to logout of email if logged in
        else if KeychainWrapper.standard.hasValue(forKey: "KEY_UID"){
            let firebaseAuth = Auth.auth()
            do {
                try firebaseAuth.signOut()
            } catch let signOutError as NSError {
                print ("Error signing out: %@", signOutError)
            }
            print("did logout of email")
            let removeSuccessful: Bool = KeychainWrapper.standard.removeObject(forKey: "KEY_UID")
            performSegue(withIdentifier: "toStart", sender: nil)
            print("Key removal happened:", removeSuccessful)
        }
    }
    
    @IBAction func headShotPressed(_ sender: UITapGestureRecognizer) {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func addButtonPressed(_ sender: Any) {
        performSegue(withIdentifier: "addPost", sender: nil)
    }
    
}

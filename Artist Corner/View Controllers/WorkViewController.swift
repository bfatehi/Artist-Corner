//
//  WorkViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 6/27/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import Foundation
import UIKit
import BSKeyboardControls
import Firebase
import FirebaseAuth
import MobileCoreServices
import AVKit

class WorkViewController: UIViewController, BSKeyboardControlsDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Mark: Outlets
    @IBOutlet weak var postMedia: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var workDescription: UITextField!
    @IBOutlet weak var talentDisplayed: UITextField!
    @IBOutlet weak var outsideURL: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    //Mark: Variables
    var keyboardControls: BSKeyboardControls?
    var fields = [UITextField]()
    var isKeyboardUp = false
    var contentInset = UIEdgeInsets.zero
    var ref: DatabaseReference!
    var uid = String()
    var talents = ["----", "Acting", "Comedy", "Music", "Directing", "Producing", "Cinematography", "Editing"]
    var talentPicker = UIPickerView()
    var newestPost = String()
    var mediaType = NSString()
    var mediaURL : NSURL?
    var videoURL : NSURL?
    var downURL = String()
    var thumb = UIImage()
    var thumbURL = String()
    var postInfor = String()
    var keyboardCount = Int()
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hides Keyboards when tapped outside of keyboard
        self.hideKeyboardWhenTappedAround()
        
        workDescription.delegate = self
        workDescription.tag = 0
        talentDisplayed.delegate = self
        talentDisplayed.tag = 1
        outsideURL.delegate = self
        outsideURL.tag = 2
        fields.append(workDescription)
        fields.append(talentDisplayed)
        fields.append(outsideURL)
        self.keyboardControls = BSKeyboardControls(fields: fields)
        self.keyboardControls?.delegate = self
        scrollView.delegate = self
        
        //database initialization
        ref = Database.database().reference()
        
        //picker intantiation
        talentPicker.delegate = self
        talentPicker.dataSource = self
        talentDisplayed.inputView = talentPicker
    }
    
    /////////////For Keyboard Functionality////////////////
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        addObservers()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        removeObservers()
    }
    
    func addObservers() {
        print("reaching obs add func")
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: nil){
            notification in
            self.keyboardWillShow(notification: notification)
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: nil){
            notification in
            self.keyboardWillHide(notification: notification)
        }
    }
    
    func removeObservers() {
        print("reaching obs remove func")
        NotificationCenter.default.removeObserver(self)
    }
    
    private func keyboardWillShow(notification: Notification) {
            guard let userInfo = notification.userInfo,
                let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else {
                    return
            }
            contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height-83+5, right: 0)
            scrollView.contentInset = contentInset
    }
    
    private func keyboardWillHide(notification: Notification) {
        scrollView.contentInset = UIEdgeInsets.zero
    }
    
    func keyboardControlsDonePressed(_ keyboardControls: BSKeyboardControls!) {
        keyboardControls.activeField.resignFirstResponder()
    }
    
    func keyboardControls(_ keyboardControls: BSKeyboardControls?, selectedField field: UIView?, in direction: BSKeyboardControlsDirection) {
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        keyboardControls?.activeField = textField
    }
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        keyboardControls?.activeField = textView
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // Try to find next responder
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
        }
        // Do not add a line break
        return false
    }
    /////////////End Keyboard Functionality functions/////////////
    
    
    
    /////////////Image Picker Functions///////////////
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        // Dismiss the picker if the user canceled.
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        self.mediaURL = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        self.mediaType = info[UIImagePickerController.InfoKey.mediaType] as! NSString
        
        //if type is video
        if self.mediaType.isEqual(to: kUTTypeMovie as String) {
            do {
                let asset = AVURLAsset(url: self.mediaURL! as URL , options: nil)
                let imgGenerator = AVAssetImageGenerator(asset: asset)
                imgGenerator.appliesPreferredTrackTransform = true
                let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                let thumbnail = UIImage(cgImage: cgImage)
                postMedia.image = thumbnail
                self.thumb = thumbnail
                videoURL = mediaURL
            } catch let error {
                print("*** Error generating thumbnail: \(error.localizedDescription)")
            }
        }
            
            //if type is image
        else {
            // The info dictionary may contain multiple representations of the image. You want to use the original.
            guard let selectedImage = info[.originalImage] as? UIImage else {
                fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
            }
            // Set photoImageView to display the selected image.
            postMedia.image = selectedImage
        }
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    ///////////////End Image Picker Functions/////////////
    
    
    ////////////talent picker functions////////////////
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return talents.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return talents[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        talentDisplayed.text = talents[row]
    }
    
    func pickerWillShow(notification: Notification) {
    }
    
    func pickerWillHide(notification: Notification) {
    }
    ////////////////end talent picker functions/////////////
    
    
    func commitPost(userID: String, completion: @escaping () -> Void) {
        var newestPostTemp = "temp array"
        var newPost = "0"
        ref.child("users").child(userID).child("posts").child("numberPosts").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            //print(value)
            newestPostTemp = value?["number"] as? String ?? ""
            //print("post numbers: " + newestPostTemp)
            newPost = String(Int(newestPostTemp)! + 1)
            self.newestPost = String(newPost)
            //print("number of posts is now: " + newPost)
            self.postInfo(userID: userID, newestPost: newPost){
                completion()
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func postInfo(userID: String, newestPost: String, completion: @escaping () -> Void) {
        let workDesc = workDescription.text
        let talentDis = talentDisplayed.text
        let outsideLink = outsideURL.text
        
        if !(self.outsideURL.text?.isEmpty)!{
            print("attempting to upload from outside link")
            if let postMediaData = self.postMedia.image!.jpegData(compressionQuality: 0.2){
                let postMediaUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                let storageRef = Storage.storage().reference().child(userID).child("Posts").child(newestPost)
                storageRef.putData(postMediaData, metadata: metaData){
                    (metadata, error) in
                    if error != nil {print("something went wrong with post", error!)
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let thumbnailString = url else{
                            print(error)
                            return
                        }
                        let thumbnailURL = thumbnailString.absoluteString
                        print("thumbnail url retrieved")
                        self.postInfor = workDesc! + ", " + talentDis! + ", " + outsideLink! + ", " + thumbnailURL
                        self.ref.child("users").child(userID).child("posts").child(String(newestPost)).setValue(["postInfo": self.postInfor])
                        self.downURL = outsideLink!
                        completion()
                    }
                }
            }
        }else if self.mediaType.isEqual(to: kUTTypeMovie as String) {
            print("attempting to upload video")
            //            if let postMediaData = UIImageJPEGRepresentation(self.postMedia.image!, 0.2){
            if let postMediaData = self.generateThumbnail(url: videoURL! as URL)!.jpegData(compressionQuality: 0.2){
                if videoURL == mediaURL{
                    self.thumbUpload(){
                        let postMediaUID = NSUUID().uuidString
                        let metaData = StorageMetadata()
                        metaData.contentType = "video/quicktime"
                        var ext = URL(fileURLWithPath: (self.videoURL?.absoluteString)!).pathExtension
                        print(ext)
                        let storageRef = Storage.storage().reference().child(userID).child("Posts").child(newestPost).child("post." + ext)
                        
                        if let videoData = NSData(contentsOf: self.videoURL as! URL) as Data? {
                            //use 'putData' instead
                            let uploadTask = storageRef.putData(videoData, metadata: metaData){
                                (metadata, error) in
                                if error != nil {print("something went wrong with post", error!)
                                    return
                                }
                                storageRef.downloadURL { (url, error) in
                                    guard let urlString = url else{
                                        print("error point one: ", error)
                                        return
                                    }
                                    let downloadURL = urlString.absoluteString
                                    self.postInfor = workDesc! + ", " + talentDis! + ", " + downloadURL + ", " + self.thumbURL
                                    //print(postInfor)
                                    self.ref.child("users").child(userID).child("posts").child(String(newestPost)).setValue(["postInfo": self.postInfor])
                                    self.downURL = downloadURL
                                    completion()
                                }
                            }
                        }
                    }
                }
            }
        }else {
            print("attempting to upload pic")
            if let postMediaData = self.postMedia.image!.jpegData(compressionQuality: 0.2){
                let postMediaUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                let storageRef = Storage.storage().reference().child(userID).child("Posts").child(newestPost)
                storageRef.putData(postMediaData, metadata: metaData){
                    (metadata, error) in
                    if error != nil {print("something went wrong with post", error!)
                        return
                    }
                    
                    storageRef.downloadURL { (url, error) in
                        guard let urlString = url else{
                            print(error)
                            return
                        }
                        let downloadURL = urlString.absoluteString
                        print("download url retrieved")
                        self.postInfor = workDesc! + ", " + talentDis! + ", " + downloadURL
                        self.ref.child("users").child(userID).child("posts").child(String(newestPost)).setValue(["postInfo": self.postInfor])
                        self.downURL = downloadURL
                        completion()
                    }
                }
            }
        }
    }
    
    func thumbUpload(completion: @escaping () -> Void) {
        let userID = Auth.auth().currentUser?.uid
        if let postMediaData = self.thumb.jpegData(compressionQuality: 0.2){
            let postMediaUID = NSUUID().uuidString
            let metaData = StorageMetadata()
            let storageRef = Storage.storage().reference().child(userID!).child("Posts").child(newestPost).child("thumb")
            storageRef.putData(postMediaData, metadata: metaData){
                (metadata, error) in
                if error != nil {print("something went wrong with post", error!)
                    return
                }
                
                ////changed for pod update
                
                storageRef.downloadURL { (url, error) in
                    guard let urlString = url else{
                        print(error)
                        return
                    }
                    let downloadURL = urlString.absoluteString
                    print("download url retrieved")
                    self.thumbURL = downloadURL
                    completion()
                }
            }
        }
    }
    
    func generateThumbnail(url: URL) -> UIImage? {
        do {
            let asset = AVURLAsset(url: url)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            // Select the right one based on which version you are using
            // Swift 4.2
            //let cgImage = try imageGenerator.copyCGImage(at: .zero, actualTime: nil)
            // Swift 4.0
            let cgImage = try imageGenerator.copyCGImage(at: CMTime.zero, actualTime: nil)
            
            
            return UIImage(cgImage: cgImage)
        } catch {
            print(error.localizedDescription)
            
            return nil
        }
    }
    
    func dismissalPrep(completion: @escaping () -> Void){
        print("dismissal prep reached")
        if let presenter = self.navigationController!.children[0] as? ShowcaseViewController{
            
            let talent = self.talentDisplayed.text
            let description = self.workDescription.text
            if postInfor.components(separatedBy: ", ").count == 3{
                let thumb = self.postMedia.image
            }else{
                let thumb = self.thumb
            }
            let newPost = true
            
            if presenter.postInfoArray[0] == "Click the + button in the top right of the screen to add your first post!, No Post Added Yet" {
                print("reaching first post loop")
                presenter.postInfoArray[0] = (self.postInfor)
                presenter.newImage = thumb
                presenter.newPost = newPost
                presenter.firstPost = newPost
                presenter.numPosts = presenter.numPosts + 1
                //presenter.testPrint()
                completion()
            }else{
                print("adding new post to presenter")
                print("old last: ", presenter.postInfoArray.last)
                presenter.postInfoArray.append(self.postInfor)
                print("new last: ", presenter.postInfoArray.last)
                presenter.newImage = thumb
                presenter.newPost = newPost
                presenter.numPosts = presenter.numPosts + 1
                //presenter.testPrint()
                completion()
            }
        }else{
            print("error with presenter variable")
        }
    }
    
    
    //Mark: Action Functions
    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        guard let owningNavigationController = navigationController else {
            fatalError("The AddWorkVC is not inside a navigation controller.")
        }
        
        if owningNavigationController.presentingViewController?.presentedViewController == owningNavigationController {
            // modal
//            self.removeObservers()
            owningNavigationController.dismiss(animated: true, completion: nil)
        } else {
            // push
//            self.removeObservers()
            owningNavigationController.popViewController(animated: true)
        }
        
    }
    
    @IBAction func imagePressed(_ sender: Any) {
        //hide keyboard
        //keyboardControls?.activeField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // allow videos or pictures
        imagePickerController.mediaTypes = ["public.image", "public.movie"]
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func savePressed(_ sender: UIBarButtonItem) {
        //need to upload relevant data to database for new post
        let userID = Auth.auth().currentUser?.uid
        
        //if values are full, create the post
        if !(self.workDescription.text?.isEmpty)! && !(self.talentDisplayed.text?.isEmpty)!{
            self.commitPost(userID: userID!){
                //must dismiss
                guard let owningNavigationController = self.navigationController else {
                    fatalError("The AddWorkVC is not inside a navigation controller.")
                }
                self.ref.child("users").child(userID!).child("posts").child("numberPosts").setValue(["number": self.newestPost])
                if owningNavigationController.presentingViewController?.presentedViewController == owningNavigationController {
                    // modal
//                    self.removeObservers()
                    self.dismissalPrep() {
                        owningNavigationController.dismiss(animated: true, completion: nil)
                    }
                } else {
                    // push
//                    self.removeObservers()
                    self.dismissalPrep {
                        owningNavigationController.popViewController(animated: true)
                    }
                }
            }
            
        }else{
            //Tell user that post can't be created unless values are full:
            
            // create the alert
            let alert = UIAlertController(title: "Must Fill Info Fields!", message: "We want people to understand your work!", preferredStyle: UIAlertController.Style.alert)
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
}

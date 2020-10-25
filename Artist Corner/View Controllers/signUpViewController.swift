//
//  signUpViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 5/5/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import FBSDKCoreKit
import FBSDKLoginKit
import BSKeyboardControls

class signUpViewController: UIViewController, BSKeyboardControlsDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    //Mark: Outlets
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var talentField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var locationField: UITextField!
    @IBOutlet weak var contactField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var headShot: UIImageView!
    @IBOutlet weak var genderField: UITextField!
    
 
    //Mark: Variables
    var keyboardControls: BSKeyboardControls?
    var fields = [UITextField]()
    var isKeyboardUp = false
    var contentInset = UIEdgeInsets.zero
    var contentOffset = CGPoint(x: 0, y: 0)
    var ref: DatabaseReference!
    var uid = String()
    var genders = ["----", "Male", "Female", "Other"]
    var genderPicker = UIPickerView()
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hides Keyboards when tapped outside of keyboard
        self.hideKeyboardWhenTappedAround()
        
        //Adding keyboard Controls
        nameField.delegate = self
        nameField.tag = 0
        talentField.delegate = self
        talentField.tag = 1
        locationField.delegate = self
        locationField.tag = 2
        contactField.delegate = self
        contactField.tag = 3
        genderField.delegate = self
        genderField.tag = 4
        fields.append(nameField)
        fields.append(talentField)
        fields.append(locationField)
        fields.append(contactField)
        fields.append(genderField)
        self.keyboardControls = BSKeyboardControls(fields: fields)
        self.keyboardControls?.delegate = self
        scrollView.delegate = self
        
        
        //database initialization
        ref = Database.database().reference()
        
        //picker intantiation
        genderPicker.delegate = self
        genderPicker.dataSource = self
        genderField.inputView = genderPicker
    }
    
    override func viewDidAppear(_ animated: Bool) {
        //Check to see if user if fully registered and if so, send to corner
        if KeychainWrapper.standard.string(forKey: "JOINED_UID") != nil {
            self.performSegue(withIdentifier: "toApp", sender: nil)
        }
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
        NotificationCenter.default.removeObserver(self)
    }
    
    private func keyboardWillShow(notification: Notification) {
        guard let userInfo = notification.userInfo,
            let frame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
                else {
                    return
                }
        contentInset = UIEdgeInsets(top: 0, left: 0, bottom: frame.height+5, right: 0)
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
        if let nextField = keyboardControls?.activeField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
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
        // The info dictionary may contain multiple representations of the image. You want to use the original.
        guard let selectedImage = info[.originalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        // Set photoImageView to display the selected image.
        headShot.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    ///////////////End Image Picker Functions/////////////
    
    
    ////////////gender picker functions////////////////
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return genders.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return genders[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        genderField.text = genders[row]
    }
    
    func pickerWillShow(notification: Notification) {
    }
    
    func pickerWillHide(notification: Notification) {
    }
    ////////////////end gender picker functions/////////////
    
    func addInfo() {
        let userID = Auth.auth().currentUser?.uid
        if let name = nameField.text, let talent = talentField.text, let location = locationField.text, let contact = contactField.text, let gender = genderField.text{
            
            let first = name.components(separatedBy: " ")[0]//need to unwrap name to choose first
            let last = name.components(separatedBy: " ")[1]//need to unwrap name to choose last
            let date = datePicker.date.description.components(separatedBy: " ")[0]//need to unwrap date to eliminate time aspect
            
            self.ref.child("users").child(userID!).child("first").setValue(["first": first])
            self.ref.child("users").child(userID!).child("last").setValue(["last": last])
            self.ref.child("users").child(userID!).child("talent").setValue(["talent": talent])
            self.ref.child("users").child(userID!).child("location").setValue(["location": location])
            self.ref.child("users").child(userID!).child("contact").setValue(["contact": contact])
            self.ref.child("users").child(userID!).child("gender").setValue(["gender": gender])
            self.ref.child("users").child(userID!).child("DOB").setValue(["DOB": date])
            self.ref.child("users").child(userID!).child("posts").child("numberPosts").setValue(["number": "0"])
            self.ref.child("users").child(userID!).child("apps").setValue(["apps": ""])
            self.ref.child("users").child(userID!).child("projects").setValue(["projects": ""])
            
            
            //need to fix this
            //Add headshot
            if let headshotData = self.headShot.image!.jpegData(compressionQuality: 0.2){
                let headShotUID = NSUUID().uuidString
                let metaData = StorageMetadata()
                let storageRef = Storage.storage().reference().child(userID!).child("headShot")
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
                        self.ref.child("users").child(userID!).child("headShot").setValue(["headShotURL": downloadURL])
                        
                        print("headshot url retrieved")
                    }
                }
            }
            
            print("added user info")
        }
    }
    
    
    //Mark: Action Functions
    @IBAction func joinPressed(_ sender: Any) {
        self.addInfo()
        //If complete, set joined key to true and send to corner
        KeychainWrapper.standard.set("true", forKey: "JOINED_UID")
        //delay for a second so database can upload before segue
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { // change 1 to desired number of seconds
            self.performSegue(withIdentifier: "toApp", sender: nil)
        }
    }
    
    @IBAction func imagePicker(_ sender: UITapGestureRecognizer) {
        //hide keyboard
        //keyboardControls?.activeField.resignFirstResponder()
        
        // UIImagePickerController is a view controller that lets a user pick media from their photo library.
        let imagePickerController = UIImagePickerController()
        
        // Only allow photos to be picked, not taken.
        imagePickerController.sourceType = .photoLibrary
        
        // Make sure ViewController is notified when the user picks an image.
        imagePickerController.delegate = self
        present(imagePickerController, animated: true, completion: nil)
    }
    
    @IBAction func skipPressed(_ sender: Any) {
        //Do nothing if skip is pressed
        print("Skip Pressed")
        let userID = Auth.auth().currentUser?.uid
        self.performSegue(withIdentifier: "toApp", sender: nil)
        self.ref.child("users").child(userID!).child("posts").child("numberPosts").setValue(["number": "0"])
    }
    
    
}

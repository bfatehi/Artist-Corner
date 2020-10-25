//
//  AuthenticationViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 4/11/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import FBSDKCoreKit
import FBSDKLoginKit
import BSKeyboardControls


class AuthenticationViewController: UIViewController, FBSDKLoginButtonDelegate, BSKeyboardControlsDelegate, UITextFieldDelegate, UITextViewDelegate {
    
    
    //Mark: Outlets
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var fbLoginButton: FBSDKLoginButton!
    
    
    //Mark: Variables
    var keyboardControls: BSKeyboardControls?
    var fields = [UITextField]()
    var isKeyboardUp = false
    var contentInset = UIEdgeInsets.zero
    
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //Hides Keyboards when tapped outside of keyboard
        self.hideKeyboardWhenTappedAround()
        
        //Adding keyboard Controls
        emailField.delegate = self
        emailField.tag = 0
        passwordField.delegate = self
        passwordField.tag = 1
        fields.append(emailField)
        fields.append(passwordField)
        self.keyboardControls = BSKeyboardControls(fields: fields)
        self.keyboardControls?.delegate = self
        scrollView.delegate = self
        
        //For Facebook Login
        fbLoginButton.delegate = self
        fbLoginButton.readPermissions = ["email"]
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
//        //Check to see if user if fully registered and if so, send to corner
        if (KeychainWrapper.standard.string(forKey: "JOINED_UID") != nil || KeychainWrapper.standard.string(forKey: "JOINED_UIDFB") != nil) && (KeychainWrapper.standard.string(forKey: "KEY_UID") != nil || KeychainWrapper.standard.string(forKey: "KEY_UID_FB") != nil) {
            self.removeObservers()
            self.performSegue(withIdentifier: "toAppStart", sender: nil)
        }
        //Check to see if user exists and if it does, send to finish sign up
        if KeychainWrapper.standard.string(forKey: "KEY_UID") != nil {
            self.removeObservers()
            self.performSegue(withIdentifier: "toSignUp", sender: nil)
        }
        //Check to see if user signed in with facebook but didnt finish sign up
        else if KeychainWrapper.standard.string(forKey: "KEY_UID_FB") != nil {
            self.removeObservers()
            self.performSegue(withIdentifier: "toSignUpFB", sender: nil)
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
        print("reaching remove func")
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
        if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
            nextField.becomeFirstResponder()
        } else {
            // Not found, so remove keyboard.
            textField.resignFirstResponder()
            signInPressed(textField.returnKeyType)
        }
        // Do not add a line break
        return false
    }
    /////////////End Keyboard Functionality functions/////////////
    
    
    ////////Method for facebook login/////////
    func loginButtonDidLogOut(_ loginButton: FBSDKLoginButton!) {
        //logout function
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
        } catch let signOutError as NSError {
            print ("Error signing out: %@", signOutError)
        }
        print("did logout of fb")
    }
    
    func loginButton(_ loginButton: FBSDKLoginButton!, didCompleteWith result: FBSDKLoginManagerLoginResult!, error: Error!) {
        //What happens at login
        let accessToken = FBSDKAccessToken.current()
        guard let accessTokentring = accessToken?.tokenString else {return}
        let credentials = FacebookAuthProvider.credential(withAccessToken: accessTokentring)
        Auth.auth().signIn(with: credentials, completion: { (user, error) in
            if error != nil {
                print("something went wrong", error!)
                return
            }
            print("successfully logged in user", user!)
            //NEED TO HAVE KEYCHAINWRAPPER ACTUALLY STORE USER.UID
            self.storeUserDataFB(uid: (user?.uid)!)
            let saveSuccessful: Bool = KeychainWrapper.standard.set((user?.uid)!, forKey: "KEY_UID_FB")
            print(saveSuccessful)
            print(user?.uid)
            print(KeychainWrapper.standard.string(forKey: "KEY_UID_FB"))
            
            if KeychainWrapper.standard.string(forKey: "JOINED_UIDFB") != nil {
                self.removeObservers()
                self.performSegue(withIdentifier: "toAppStart", sender: nil)
            }else{
                self.removeObservers()
                self.performSegue(withIdentifier: "toSignUpFB", sender: nil)
            }
        })
    }
    
    func storeUserData(uid: String) {
        //adds initial setup data such as username(email)
        Database.database().reference().child("users").child(uid).child("username").setValue(["username": self.emailField.text])
    }
    
    func storeUserDataFB(uid: String) {
        //adds initial setup data
        if((FBSDKAccessToken.current()) != nil){
            FBSDKGraphRequest(graphPath: "me", parameters: ["fields": "id, first_name, last_name, email"]).start(completionHandler: { (connection, result, error) -> Void in
                if (error == nil){
                    let data:[String:AnyObject] = result as! [String : AnyObject]
                    let fbID = data["id"]!
                    let headShot = "https://graph.facebook.com/\(fbID)/picture?type=large"
                    let first = data["first_name"]!
                    let last = data["last_name"]!
                    let email = data["email"]!
                Database.database().reference().child("users").child(uid).child("username").setValue(["username": email])
                Database.database().reference().child("users").child(uid).child("first").setValue(["first": first])
                Database.database().reference().child("users").child(uid).child("last").setValue(["last": last])
                Database.database().reference().child("users").child(uid).child("headShot").setValue(["headShotURL": headShot])
                    
                    print("successfully added facebook data to firebase")
                }else{
                    print(error)
                }
            })
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    //Mark: Actions
    @IBAction func signInPressed(_ sender: Any) {
        //signing in using email
        print("button pressed")
        if let email = emailField.text, let password = passwordField.text {
            print(email)
            print(emailField.text)
            print(password)
            print(passwordField.text)
            
            Auth.auth().signIn(withEmail: email, password: password) { (firUser, error) in
                if error != nil && !(self.emailField.text?.isEmpty)! && !(self.passwordField.text?.isEmpty)! {
                    print("No User")
                    Auth.auth().createUser(withEmail: email, password: password){
                        (firUser, error) in
                        if (firUser?.user.uid) != nil && (error == nil){
                            //trying inside of creation
                            self.storeUserData(uid: (firUser?.user.uid)!)
                            KeychainWrapper.standard.set((firUser?.user.uid)!, forKey: "KEY_UID")
                            print(KeychainWrapper.standard.string(forKey: "KEY_UID"))
                            KeychainWrapper.standard.removeObject(forKey: "JOINED_UID")
                            self.removeObservers()
                            self.performSegue(withIdentifier: "toSignUp", sender: nil)
                            
                        }else {
                            print("password incorrect")
                            print(error)
                        }
                    }
                } else {
                    if let userID = firUser?.user.uid {
                        print("User Exists")
                        KeychainWrapper.standard.set((userID), forKey: "KEY_UID")
                        
                        if KeychainWrapper.standard.string(forKey: "JOINED_UID") != nil {
                            self.removeObservers()
                            self.performSegue(withIdentifier: "toAppStart", sender: nil)
                        }else {
                            self.removeObservers()
                            self.performSegue(withIdentifier: "toSignUp", sender: nil)
                        }
                    }
                }
            }
        }else {
            //if both of fields aren't filled, the user cannot login (must tell them this)
            let alert = UIAlertController(title: "Must Fill Both Fields!", message: "We need this info to setup your profile!", preferredStyle: UIAlertController.Style.alert)
            
            // add an action (button)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            
            // show the alert
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func loginFacebookAction(_ sender: Any) {
        //logic already set with the loginButton function
    }
    
    
    
}


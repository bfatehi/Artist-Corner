//
//  AddProjectViewController.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/12/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import UIKit
import Firebase
import FirebaseAuth
import SwiftKeychainWrapper
import BSKeyboardControls

class AddProjectViewController: UIViewController, BSKeyboardControlsDelegate, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    //Mark: Variables
    @IBOutlet weak var projectName: UITextField!
    @IBOutlet weak var projectArt: UIImageView!
    @IBOutlet weak var projectStatus: UITextField!
    @IBOutlet weak var projectDesc: UITextField!
    @IBOutlet weak var scrollView: UIScrollView!
    
    var project = Project()
    var userID = String()
    var keyboardControls: BSKeyboardControls?
    var fields = [UITextField]()
    var isKeyboardUp = false
    var contentInset = UIEdgeInsets.zero
    var statuses = ["----", "Initiated", "Planning", "Execution", "Closed"]
    var statusPicker = UIPickerView()
    var art = UIImage()
    var curProj = Int()
    var keyboardCount = Int()
    
    //Mark: Functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //userID = KeychainWrapper.standard.string(forKey: "KEY_UID")!
        userID = (Auth.auth().currentUser?.uid)!
        
        self.hideKeyboardWhenTappedAround()
        projectName.delegate = self
        projectName.tag = 0
        projectStatus.delegate = self
        projectStatus.tag = 1
        projectDesc.delegate = self
        projectDesc.tag = 2
        fields.append(projectName)
        fields.append(projectStatus)
        fields.append(projectDesc)
        self.keyboardControls = BSKeyboardControls(fields: fields)
        self.keyboardControls?.delegate = self
        scrollView.delegate = self
        
        statusPicker.delegate = self
        statusPicker.dataSource = self
        projectStatus.inputView = statusPicker
        
        print("the project.name looks like this: ", project.name)
        
        if project.name != nil{
            projectName.text = project.name
            projectStatus.text = project.status
            projectDesc.text = project.descript
            self.downloadImageHeadShot(url: NSURL(string: project.art!) as! URL, imageView: projectArt)
        }
        
        // Do any additional setup after loading the view.
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
    
    ////////////status picker functions////////////////
    // returns the number of 'columns' to display.
    public func numberOfComponents(in pickerView: UIPickerView) -> Int{
        return 1
    }
    
    // returns the # of rows in each component..
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return statuses.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String?{
        return statuses[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int){
        projectStatus.text = statuses[row]
    }
    
    func pickerWillShow(notification: Notification) {
    }
    
    func pickerWillHide(notification: Notification) {
    }
    ////////////////end status picker functions/////////////
    
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
        projectArt.image = selectedImage
        
        // Dismiss the picker.
        dismiss(animated: true, completion: nil)
    }
    ///////////////End Image Picker Functions/////////////
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        switch (segue.identifier ?? "") {
        case "Team":
            guard let teamAddController = segue.destination as? TeamAddViewController
                else{
                    fatalError("Unexpected destination: \(segue.destination)")
            }
            project.ownerUID = userID
            project.descript = projectDesc.text
            project.name = projectName.text
            project.status = projectStatus.text
            self.art = projectArt.image!
            
            teamAddController.project = self.project
            teamAddController.art = self.art
            teamAddController.curProj = self.curProj
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    //Mark: Actions
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

    @IBAction func cancelPressed(_ sender: UIBarButtonItem) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func nextPressed(_ sender: UIBarButtonItem) {
        //use prepare statement to pass project info to team part
        performSegue(withIdentifier: "Team", sender: sender)
    }

}

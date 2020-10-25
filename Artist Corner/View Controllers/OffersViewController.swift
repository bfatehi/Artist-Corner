//
//  OffersViewController.swift
//  Artist Corner
//
//  Created by Brahm Fatehi on 8/14/19.
//  Copyright © 2019 Artist Corner. All rights reserved.
//

import UIKit

class OffersViewController: UIViewController {
    
    
    //Mark: outlets
    @IBOutlet weak var art: UIImageView!
    @IBOutlet weak var toggle: UISegmentedControl!
    @IBOutlet weak var container: UIView!
    @IBOutlet weak var navBar: UINavigationItem!
    
    
    //Mark: Variables
    var project = Project()
    var views: [UIView]!
    var curProj = Int()
    var projKey = String()
    var myApps = String()
    
    //Mark: Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.downloadImageHeadShot(url: NSURL(string: project.art!) as! URL, imageView: art)
        self.navBar.title = project.name
        
        print("curProj = ", curProj)
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
    
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        //        super.prepare(for: segue, sender: sender)
        //
        switch(segue.identifier ?? "") {
        case "TabBar":
            guard let TabController = segue.destination as? UITabBarController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            // Pass the selected object to the new view controller.
            if let detVC = TabController.children[0] as? ProductDetailsVC{
                detVC.project = self.project
            }
            if let teamVC = TabController.children[1] as? TeamVC{
                teamVC.project = self.project
            }
            if let rolesVC = TabController.children[2] as? RolesVC2{
                rolesVC.project = self.project
                rolesVC.projKey = self.projKey
                rolesVC.myApps = self.myApps
            }
        case "edit":
            guard let EditController = segue.destination as? AddProjectViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            EditController.project = self.project
            EditController.curProj = self.curProj
            
        default:
            fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    //Mark: Action Functions
    @IBAction func backPressed(_ sender: Any) {
        print("back pressed")
        print(self.navigationController?.children[1])
        if let presenter = self.navigationController?.children[0] as? JobsViewController{
            presenter.allProjects = []
            presenter.apps = []
            presenter.projKeys = []
            //            self.projs = []
            //            self.projects = []
            //            self.projectCount = 0
            
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    @IBAction func toggleAction(_ sender: UISegmentedControl) {
        if let tabVC = self.children[0] as? UITabBarController{
            tabVC.selectedIndex = sender.selectedSegmentIndex
        }
    }
    
}

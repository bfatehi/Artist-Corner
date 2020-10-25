//
//  Project.swift
//  Artist Corner
//
//  Created by Abraham Fatehi on 10/18/18.
//  Copyright © 2018 Artist Corner. All rights reserved.
//

import Foundation
import UIKit

class Project: NSObject{
    
    //Mark: Properties
    var ownerUID: String?
    var name: String?
    var status: String?
    var descript: String?
    var art: String?
    var team: [String?] = []
    var reqRoles: [String?] = []
    var apps: [String?] = []
    
    func toDictionary() -> [String:Any] {
        var dictionary = [String:Any]()
        dictionary["ownerUID"] = ownerUID
        dictionary["name"] = name
        dictionary["status"] = status
        dictionary["descript"] = descript
        //dictionary["art"] = ""
        dictionary["team"] = team
        dictionary["reqRoles"] = reqRoles
        dictionary["apps"] = apps
        return dictionary
    }
    
    func eraseData() {
        ownerUID = ""
        name = ""
        status = ""
        descript = ""
        team = []
        reqRoles = []
        apps = []
    }
}

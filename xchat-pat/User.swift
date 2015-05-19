//
//  User.swift
//  xchat-pat
//
//  Created by Pat Boonyarittipong on 5/18/15.
//  Copyright (c) 2015 patboony. All rights reserved.
//

import UIKit

class User: NSObject {
    var name: String?
    var username: String?
    var userId: Int?
    var email: String?
    
    var dictionary: NSDictionary?
    
    init(dictionary: NSDictionary){
        self.dictionary = dictionary
        name = dictionary["name"] as? String
        username = dictionary["username"] as? String
        userId = dictionary["userId"] as? Int
        email = dictionary["email"] as? String
    }
}

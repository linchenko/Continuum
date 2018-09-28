//
//  UserController.swift
//  Continuum
//
//  Created by Levi Linchenko on 27/09/2018.
//  Copyright © 2018 Levi Linchenko. All rights reserved.
//

import Foundation

class UserController{
    
    static let shared = UserController()
    private init () {}
    
    static var user: User?
    
    func createUser (username: String, password: String, userEmail: String){
        let user = User(username: username, userEmail: userEmail, password: password)
    }
    
}

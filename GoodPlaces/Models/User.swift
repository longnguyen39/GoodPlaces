//
//  User.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/30/21.
//
import UIKit
import Firebase

struct User {
    var email: String
    var password: String
    var username: String
    var uid: String
    var profileImageUrl: String
    var stats: UserStats!
    
    init(dictionary: [String : Any]) {
        self.email = dictionary["email"] as? String ?? "no email"
        self.password = dictionary["password"] as? String ?? "no pass"
        self.username = dictionary["username"] as? String ?? "no username"
        self.uid = dictionary["UserID"] as? String ?? "no uid"
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? "no imageURL"
        self.stats = UserStats(friends: 0, savedPlaces: 0)
        //all the shit "" must match the "" in "data" in AuthService
    }
}

struct UserStats {
    let friends: Int
    let savedPlaces: Int
}

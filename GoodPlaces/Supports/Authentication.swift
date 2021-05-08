//
//  Authentication.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/2/21.
//

import UIKit
import Firebase

struct Authentication {
    
    static func registerUser(email: String, pass: String, name: String, proImage: UIImage, completion: @escaping(Error?)->Void) {
        
        Auth.auth().createUser(withEmail: email, password: pass) { (result, error) in
            
            if let e = error?.localizedDescription {
                print("DEBUG-Authentication: error \(e)")
                return
            }
            
            guard let uid = result?.user.uid else {return}
            
            ImageUploader.uploadImage(image: proImage, mail: email) { imageUrl in
                //create an array of user info
                
                print("DEBUG: passing in url..")
                
                let data = ["username": name,
                            "email": email,
                            "password": pass,
                            "userID": uid,
                            "profileImageUrl": imageUrl]
                
                //upload to database
                Firestore.firestore().collection("users").document(email).setData(data, completion: completion)
                print("DEBUG-Authentication: done creating user")
                
            }
        }
    }
    
    static func signOut(completion: @escaping(String) -> Void) {
        let userEmail = Auth.auth().currentUser?.email ?? "nil"
        
        do {
            try Auth.auth().signOut()
            print("DEBUG-Authentication: done signing out \(userEmail)")
            completion(userEmail) //make this just for the completion block to be executed
        } catch  {
            print("DEBUG: error signing out \(userEmail)")
        }
    }
    
    
    
    
}

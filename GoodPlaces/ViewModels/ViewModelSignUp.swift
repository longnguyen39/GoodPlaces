//
//  ViewModelSignUp.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/30/21.
//

import UIKit

struct ViewModelSignUp {
    
    var username: String?
    var email: String?
    var password: String?
    
    var formIsValid: Bool {
        //if the line below is true, then we return formIsValid == true
        return email?.isEmpty == false && password?.isEmpty == false && username?.isEmpty == false
    }
}

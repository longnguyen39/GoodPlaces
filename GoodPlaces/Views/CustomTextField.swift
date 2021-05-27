//
//  CustomTextField.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit

class CustomTextField: UITextField {

    
    init(placeHolder: String? = nil) {
        super.init(frame: .zero)
        
        autocapitalizationType = .none
        font = UIFont.systemFont(ofSize: 18, weight: .regular)
        borderStyle = .none
        textColor = .black
        keyboardAppearance = .dark
        backgroundColor = UIColor(white: 1, alpha: 0.1)
        tintColor = .black //set color for the cursor
        
        //let's set the placeHolder's background color
        let placeHolderColor: UIColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        attributedPlaceholder = NSAttributedString(string: placeHolder ?? ".." , attributes: [.foregroundColor: placeHolderColor])
        
        
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

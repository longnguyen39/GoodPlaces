//
//  ProfileButtons.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/3/21.
//

import UIKit

class ProfileButtons: UIButton {
    
    
    init(title: String) {
        super.init(frame: .zero)
        
        backgroundColor = #colorLiteral(red: 0.2580253915, green: 0.4599661465, blue: 0.9686274529, alpha: 1)
        setHeight(height: 50)
        titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        setTitleColor(.white, for: .normal)
        setTitle(title, for: .normal)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

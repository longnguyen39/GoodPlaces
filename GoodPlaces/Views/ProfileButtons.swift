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
        
        backgroundColor = #colorLiteral(red: 0.4772150784, green: 1, blue: 0.5178573741, alpha: 1)
        setHeight(height: 42)
        titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .regular)
        setTitleColor(#colorLiteral(red: 0.2441921214, green: 0.331868237, blue: 0.997935557, alpha: 1), for: .normal)
        setTitle(title, for: .normal)
        layer.cornerRadius = 12
        layer.borderWidth = 1
        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
}

//
//  AuthTextField.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit

class AuthTextFieldView: UIView {
    
//MARK: - Components
    
    
    var textField: CustomTextField = CustomTextField()
    
    private let imagePict: UIImageView = {
        let im = UIImageView()
        im.tintColor = .black
        
        return im
    }()
    
//MARK: - View scenes
    
    init(imageIndicator: UIImage?, placeHolderText: String, secure: Bool? = nil) {
        super.init(frame: .zero)
        
        textField.isSecureTextEntry = secure ?? false
        
        //backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
        backgroundColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0).withAlphaComponent(0.87)
        setHeight(height: 54)
        layer.cornerRadius = 24
        layer.shadowOpacity = 0.7
        layer.shadowOffset = CGSize(width: 4, height: 4)
        
        addSubview(imagePict)
        imagePict.image = imageIndicator
        imagePict.anchor(left: leftAnchor, paddingLeft: 14)
        imagePict.centerY(inView: self)
        imagePict.setDimensions(height: 26, width: 30)
        
        addSubview(textField)
        textField.placeholder = placeHolderText
        textField.anchor(left: imagePict.rightAnchor, right: rightAnchor, paddingLeft: 10, paddingRight: 14)
        textField.centerY(inView: self)
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    
    
}

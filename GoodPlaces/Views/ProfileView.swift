//
//  ProfileView.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 5/2/21.
//

import UIKit
import Firebase
import SDWebImage

protocol ProfileViewDelegate: class {
    func replaceProfileImage()
}

class ProfileView: UIView {
    
    private var userEmail = Auth.auth().currentUser?.email
    private var imD: CGFloat = 100
    weak var delegate: ProfileViewDelegate?
    
    private var profileURL: URL? {
        return URL(string: userInfo?.profileImageUrl ?? "no url")
    }
    
//MARK: - Components
    
    //gotta make this "lazy var" to load the tap gesture. No "private" since we need to access it from SettingVC
    lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.circle")
        iv.tintColor = .lightGray
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        iv.isUserInteractionEnabled = true
        iv.layer.cornerRadius = imD / 2
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.black.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(changeProfileImage))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    //no "private" since we need to access it in SettingVC
    let usernameLabel: UILabel = {
        let lb = UILabel()
        lb.text = "username.."
        lb.font = UIFont.systemFont(ofSize: 18, weight: .bold)
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        
        return lb
    }()
    
    private let emailLabel: UILabel = {
        let lb = UILabel()
        lb.text = "email.."
        lb.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        
        return lb
    }()
    
    //make it a lazy var since we are using a func in the Helpers section
    private lazy var friendsLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
        lb.attributedText = attributedStatText(value: 0, label: "Friends")
        
        return lb
    }()
    
    private lazy var placesLabel: UILabel = {
        let lb = UILabel()
        lb.numberOfLines = .zero
        lb.textAlignment = .center
//        lb.attributedText = attributedStatText(value: 0, label: "Places")
        
        return lb
    }()
    
    //when "userInfo" got changed, the "didSet" got called. dont make it "private" since we have to access it from SettingVC, where we fill in "userInfo" with data fetched
    var userInfo: User? {
        didSet {
            usernameLabel.text = userInfo?.username
            emailLabel.text = userInfo?.email
            placesLabel.attributedText = attributedStatText(value: userInfo?.stats.savedPlaces ?? 0, label: "Saved Places")
            profileImageView.sd_setImage(with: profileURL)
        }
    }
    
//    var userStats:
    
    
//MARK: - View scenes
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white
        setHeight(height: 180)
        layer.cornerRadius = 20
        layer.shadowOffset = CGSize(width: 6, height: 6)
        layer.shadowOpacity = 0.6
        
        //profileImageView
        addSubview(profileImageView)
        profileImageView.anchor(top: topAnchor, left: leftAnchor, paddingTop: 8, paddingLeft: 8)
        profileImageView.setDimensions(height: imD, width: imD)
        
        //usernameLabel
        addSubview(usernameLabel)
        usernameLabel.anchor(top: profileImageView.bottomAnchor, left: profileImageView.leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingRight: 14)
        
        //emailLabel
        addSubview(emailLabel)
        emailLabel.anchor(top: usernameLabel.bottomAnchor, left: profileImageView.leftAnchor, right: rightAnchor, paddingTop: 8, paddingLeft: 4, paddingRight: 14)
        
        //add stats Label
//        let stack = UIStackView(arrangedSubviews: [friendsLabel, placesLabel])
//        stack.axis = .horizontal
//        stack.distribution = .equalSpacing
//        addSubview(stack)
//        stack.anchor(left: profileImageView.rightAnchor, right: rightAnchor, paddingLeft: 16, paddingRight: 16)
//        stack.centerY(inView: profileImageView)

        //placesLabel
        addSubview(placesLabel)
        placesLabel.anchor(left: profileImageView.rightAnchor, right: rightAnchor, paddingLeft: 30, paddingRight: 30)
        placesLabel.centerY(inView: profileImageView)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//MARK: - Actions
    
    @objc func changeProfileImage() {
        print("DEBUG-ProfileView: image tapped")
        delegate?.replaceProfileImage()
    }
    
    func attributedStatText(value: Int, label: String) -> NSAttributedString {
        //the "\n" means take another line. the good measure is fontSize = 22 and 16
        let attributedText = NSMutableAttributedString(string: "\(value)\n", attributes: [.font: UIFont.systemFont(ofSize: 30, weight: .bold), .foregroundColor: UIColor.black])
        attributedText.append(NSAttributedString(string: label, attributes: [.font: UIFont.systemFont(ofSize: 20), .foregroundColor: UIColor.lightGray]))
        
        return attributedText
    }
    
    
    
}


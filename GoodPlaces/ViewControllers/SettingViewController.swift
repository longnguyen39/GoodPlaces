//
//  SettingViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit


class SettingViewController: UIViewController {
    
    //MARK: - Components
    
    private let profileView = ProfileView()
    
    private let dismissButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "chevron.down"), for: .normal)
        btn.tintColor = .black
        btn.addTarget(self, action: #selector(dismissSettingVC), for: .touchUpInside)
        
        return btn
    }()
    
    
    private let editProfileImageButton = ProfileButtons(title: "Edit profile Image")
    private let editUsernameButton = ProfileButtons(title: "Edit username")
    private let showFriendlistButton = ProfileButtons(title: "Show friend list")
    private let showSavedPlacesButton = ProfileButtons(title: "Show saved places")
    
    
    private let logOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setHeight(height: 50)
        btn.setTitle("Log out", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.8929973138, green: 1, blue: 0.8881637358, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.2411971831, blue: 0.1393796313, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUserData()
        profileView.delegate = self
    }
    
    
//MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = #colorLiteral(red: 0.4156862745, green: 0.9506325946, blue: 0.9294117647, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        //dismissButton
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 4, paddingLeft: 12)
        dismissButton.setDimensions(height: 26, width: 30)
        
        //profileView
        view.addSubview(profileView)
        profileView.anchor(top: dismissButton.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 24, paddingLeft: 14, paddingRight: 14)
        
        //the 4 buttons
        let stack = UIStackView(arrangedSubviews: [editProfileImageButton, editUsernameButton, showFriendlistButton, showSavedPlacesButton])
        stack.axis = .vertical
        stack.spacing = 10
        
        view.addSubview(stack)
        stack.anchor(top: profileView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 34, paddingLeft: 50, paddingRight: 50)
        
        //logOut button
        view.addSubview(logOutButton)
        logOutButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 24, paddingBottom: 20, paddingRight: 24)
        
    }
    
    
//MARK: - Actions
    
    @objc func dismissSettingVC() {
        print("DEBUG-SettingVC: dismissButton tapped..")
        dismiss(animated: true, completion: nil)
    }
    
    @objc func logOutButtonTapped() {
        print("DEBUG-ProfileView: logOutBtn tapped")
        alertLogOut(Title: "Log out?", comment: "Are you sure want to log out?", buttonNote1: "cancel", buttonNote2: "Log out")
    }
    
    func fetchUserData() {
        //let's fill in with data
        Service.fetchUserInfo { userStuff in
            self.profileView.userInfo = userStuff //pass in the data
            
            Service.fetchUserStats { numberOfSavedPlaces in
                self.profileView.userInfo?.stats = UserStats(friends: 0, savedPlaces: numberOfSavedPlaces) //fetch stats
            }
            
        }
    }
    
    //MARK: - Authentication / API
    
    func logOut() {
        Authentication.signOut { _ in
            print("DEBUG-SettingVC: done log out, dismiss stuff")
            self.dismiss(animated: true)
            
            //let's send the notification to HomeVC to present Login page
            NotificationCenter.default.post(name: .didLogOut, object: nil)
        }
    }
    
    //let do some alerts signIn
    func alertLogOut (Title: String, comment: String, buttonNote1: String, buttonNote2: String) {
        
        let alert = UIAlertController (title: Title, message: comment, preferredStyle: .actionSheet)
        let action1 = UIAlertAction (title: buttonNote1, style: .cancel, handler: nil)
        let action2 = UIAlertAction (title: buttonNote2, style: .destructive) { (action) in
            self.logOut()
        }
        
        alert.addAction(action1)
        alert.addAction(action2)
        present (alert, animated: true, completion: nil)
    }

}

//MARK: - ProfileView Delegate
//remember to write ".delegate = self" in the ViewDidLoad
extension SettingViewController: ProfileViewDelegate {
    func showLogin() {
        print("DEBUG-SettingVC: protocol from ProfileView")
        
    }
    
    
}

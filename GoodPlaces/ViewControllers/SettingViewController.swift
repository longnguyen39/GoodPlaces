//
//  SettingViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit
import Firebase

class SettingViewController: UIViewController {
    
    private var newUsername = "username"
    
//MARK: - Components
    
    private let profileView = ProfileView()
    
    private let editProfileImageButton = ProfileButtons(title: "Edit profile Image")
    private let editUsernameButton = ProfileButtons(title: "Edit username")
    
    
    private let logOutButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setHeight(height: 50)
        btn.setTitle("Log out", for: .normal)
        btn.setTitleColor(.white, for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.8549019694, green: 0.2411971831, blue: 0.1393796313, alpha: 1)
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .medium)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        btn.addTarget(self, action: #selector(logOutButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        fetchUserData()
        swipeGesture()
        profileView.delegate = self
        
        editUsernameButton.addTarget(self, action: #selector(changeUsername), for: .touchUpInside)
        editProfileImageButton.addTarget(self, action: #selector(changeProfileImage), for: .touchUpInside)
    }
    
    
//MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = #colorLiteral(red: 0.8458681778, green: 0.9506325946, blue: 0.8147001801, alpha: 1)
        
        //let's set nav bar
        navigationController?.navigationBar.isHidden = false
        configureNavigationBar(title: "Setting", preferLargeTitle: false, backgroundColor: #colorLiteral(red: 0.4772150784, green: 1, blue: 0.517582286, alpha: 1), buttonColor: .black)
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "chevron.down"), style: .done, target: self, action: #selector(dismissSettingVC))
        
        //profileView
        view.addSubview(profileView)
        profileView.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 24, paddingLeft: 14, paddingRight: 14)
        
        //the 2 buttons
        let stack = UIStackView(arrangedSubviews: [editProfileImageButton, editUsernameButton])
        stack.axis = .vertical
        stack.spacing = 20
        
        view.addSubview(stack)
        stack.anchor(top: profileView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 34, paddingLeft: 50, paddingRight: 50)
        
        //logOut button
        view.addSubview(logOutButton)
        logOutButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 24, paddingBottom: 20, paddingRight: 24)
        
    }
    
    
//MARK: - Actions
    
    func swipeGesture() {
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissSettingVC))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
    }
    
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
    
    @objc func changeUsername() {
        textBox()
    }
    
    @objc func changeProfileImage() {
        imageTapped()
    }
    
//MARK: - Text Box
    
    func textBox() {
        var textField = UITextField()
        
        let alertBox = UIAlertController(title: "Edit username", message: "Rename to...", preferredStyle: .alert)
        let cancel = UIAlertAction (title: "Cancel", style: .cancel, handler: nil)
        let action = UIAlertAction(title: "Save", style: .default) { (action) in
            //let's verify the textField
            if textField.text?.isEmpty == false && textField.text?.starts(with: " ") == false {
                
                self.showPresentLoadingView(true, message: "Saving")
                self.newUsername = textField.text!
                print("DEBUG-SettingVC: newName is \(self.newUsername)")
                self.updateUsername()
                
            } else {
                print("DEBUG: textField is empty..")
                self.alert(error: "Please enter a valid input", buttonNote: "Try again")
            }
        }
        alertBox.addTextField { (alertTextField) in
            guard let currentUsername = self.profileView.usernameLabel.text else { return }
            alertTextField.text = currentUsername
            alertTextField.placeholder = "New username.."
            alertTextField.autocapitalizationType = .words
            
            textField = alertTextField
        }
        alertBox.addAction(cancel)
        alertBox.addAction(action)
        present(alertBox, animated: true, completion: nil)
    }
    
    func updateUsername() {
        print("DEBUG-MapVC: updating title..")
        guard let userEmail = profileView.userInfo?.email else { return }
        
        let data = ["username": newUsername] as [String: Any]
        
        Firestore.firestore().collection("users").document(userEmail).updateData(data) { error in
            
            self.showPresentLoadingView(false, message: "Saving")
            if let e = error?.localizedDescription {
                print("DEBUG-SettingVC: error updating username - \(e)")
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            
            self.successfullyUpdateUsername()
        }
    }
    
    func successfullyUpdateUsername() {
        self.showSuccess(show: true, note: "Saved", view: self.view)
        print("DEBUG-SettingVC: successfully update username")
        self.profileView.usernameLabel.text = newUsername
        self.showSuccess(show: false, note: "Saved", view: self.view) //got delay a bit to show success mark
        
        //send notification to HomeVC
        NotificationCenter.default.post(name: .didChangeUserInfo, object: nil)
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
    
//MARK: - change profileImage
    func imageTapped() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    func uploadNewProfileImage() {
        
        guard let newImage = profileView.profileImageView.image else { return }
        guard let email = profileView.userInfo?.email else { return }
        
        ImageUploader.uploadImage(image: newImage, mail: email) { imageUrl in
                        
            let data = ["profileImageUrl": imageUrl]
            
            //upload to database
            Firestore.firestore().collection("users").document(email).updateData(data) { error in
                
                self.showPresentLoadingView(false, message: "Saving..")
                if let e = error?.localizedDescription {
                    print("DEBUG-SettingVC: error changing proImage - \(e)")
                    self.showLoader(show: false, view: self.view)
                    self.alert(error: e, buttonNote: "Try again")
                    return
                }
                self.showSuccess(show: true, view: self.view)
                print("DEBUG-SettingVC: done uploading new profileImage")
                self.showSuccess(show: false, view: self.view)
                //send notification to HomeVC
                NotificationCenter.default.post(name: .didChangeUserInfo, object: nil)
            }
            
        }
    }

}

//MARK: - ProfileView Delegate
//remember to write ".delegate = self" in the ViewDidLoad
extension SettingViewController: ProfileViewDelegate {
    func replaceProfileImage() {
        print("DEBUG-SettingVC: protocol from ProfileView to change profile Image")
        imageTapped()
        
    }
    
    
}

//MARK: - Extension for ImagePicker

extension SettingViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //this func gets called once user has just chose a pict
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        print("DEBUG: just finished picking a photo")
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("DEBUG: error setting selectedImage")
            return
        }
        
        //let's set the button image to the selected image
        profileView.profileImageView.layer.cornerRadius = profileView.profileImageView.frame.width/2
        profileView.profileImageView.layer.masksToBounds = true
        profileView.profileImageView.layer.borderWidth = 2
        profileView.profileImageView.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        profileView.profileImageView.image = selectedImage
        
        self.dismiss(animated: true, completion: nil)
        showPresentLoadingView(true, message: "Saving..")
        uploadNewProfileImage()
    }
}

//
//  SignupViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit
import Firebase
import JGProgressHUD

class SignupViewController: UIViewController {
    
    private var logoD: CGFloat = 120
    private var viewModel = ViewModelSignUp()
    
    //MARK: - Components
    
    private var backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "city").withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "GoodPlaces"
        //lb.font = UIFont(name: "Avenir-Light", size: 36)
        lb.font = UIFont.systemFont(ofSize: 30, weight: .regular)
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        
        return lb
    }()
    
    private lazy var profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.image = UIImage(systemName: "person.badge.plus")
        iv.tintColor = .black
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
        iv.layer.backgroundColor = UIColor.white.cgColor
        iv.isUserInteractionEnabled = true
        iv.layer.borderWidth = 1
        iv.layer.borderColor = UIColor.black.cgColor
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(imageTapped))
        iv.addGestureRecognizer(tap)
        
        return iv
    }()
    
    private var profileImage: UIImageView = {
        let pi = UIImageView()
        pi.image = UIImage(systemName: "person.circle") //let's set a default profileImage in case user dont want to set the profileImage when registering
        return pi
    }()
    
    private let usernameInputView = AuthTextFieldView(imageIndicator: UIImage(systemName: "person"), placeHolderText: "username..")
    
    private let emailInputView = AuthTextFieldView(imageIndicator: UIImage(systemName: "envelope"), placeHolderText: "Email..")
    
    private let passwordInputView = AuthTextFieldView(imageIndicator: UIImage(systemName: "lock"), placeHolderText: "Password..", secure: true)
    
    
    private let signUpButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setHeight(height: 50)
        btn.setTitle("Sign Up", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        btn.alpha = 0.8
        btn.isEnabled = false
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let backButton: UIButton = {
        let btn = UIButton(type: .system)
        let textColor: UIColor = #colorLiteral(red: 0.1521535128, green: 0.9202688047, blue: 0.9764705896, alpha: 1)
        let attributedTitle = NSMutableAttributedString (string: "Already have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: textColor])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign In", attributes: [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.yellow]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(backToLogIn), for: .touchUpInside)
        
        return btn
    }()
    
    
    
    //MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HideKeyBoard()
        configureUI()
        formValidation()
        
        
    }
    
    
    //MARK: - Configure UI
    
    func configureUI() {
        view.backgroundColor = .yellow
        
        //backgroundImage
        view.addSubview(backgroundImage)
        backgroundImage.frame = view.bounds

        //titleLabel and logoIcon
        view.addSubview(titleLabel)
        titleLabel.anchor(top: view.safeAreaLayoutGuide.topAnchor, paddingTop: 10)
        titleLabel.centerX(inView: view)
        
        view.addSubview(profileImageView)
        profileImageView.anchor(top: titleLabel.bottomAnchor, paddingTop: 14)
        profileImageView.centerX(inView: view)
        profileImageView.setDimensions(height: logoD, width: logoD)
        profileImageView.layer.cornerRadius = logoD/2
        
        //TextView
        let stack  = UIStackView(arrangedSubviews: [usernameInputView, emailInputView, passwordInputView, signUpButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: profileImageView.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 24, paddingRight: 24)
        
        //backButton
        view.addSubview(backButton)
        backButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
    }
    
    
//MARK: - Actions
    
    //let's deal with the keyboard without the use of IQKeyboardManager (tap anywhere to dismiss it)
    func HideKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        print("DEBUG: dismissing keyboard..")
        view.endEditing(true)
    }
    
    @objc func backToLogIn() {
        navigationController?.popViewController(animated: true)
    }
    
//MARK: - checking form
    func formValidation() {
        usernameInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        emailInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
        passwordInputView.textField.addTarget(self, action: #selector(textDidChange), for: .editingChanged)
    }
    
    @objc func textDidChange (sender: UITextField) {
        if sender == emailInputView.textField {
            viewModel.email = sender.text
        }
        else if sender == passwordInputView.textField {
            viewModel.password = sender.text
        }
        else if sender == usernameInputView.textField {
            viewModel.username = sender.text
        }
        
        checkFormStatus() //we have the viewModel all filled up with text
    }
    
    func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            signUpButton.isEnabled = true
            signUpButton.backgroundColor = #colorLiteral(red: 0.9073992463, green: 1, blue: 0, alpha: 1)
            signUpButton.alpha = 1
        } else {
            signUpButton.isEnabled = false
            signUpButton.backgroundColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            signUpButton.alpha = 0.8
            signUpButton.setTitleColor(.black, for: .normal)
        }
    }
    
    //MARK: - sign up user
    @objc func signUpButtonTapped() {
        print("DEBUG-from SignupVC: signUpButton tapped")
        DismissKeyboard()
        showLoader(show: true, text: "Signing up", view: view)
        
        //the viewModel is filled with text in "formValidation"
        guard let usernameTyped = viewModel.username else { return }
        guard let emailTyped = viewModel.email else { return }
        guard let passwordTyped = viewModel.password else { return }
        guard let image = self.profileImage.image else { return }
        
        Authentication.registerUser(email: emailTyped, pass: passwordTyped, name: usernameTyped, proImage: image) { error in
            
            print("DEBUG: evaluating registered user")
            self.showLoader(show: false, view: self.view)
            
            if let e = error?.localizedDescription {
                print("DEBUG: error registering user..\(e)")
                return
            }
            
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeViewController else { return }
            controller.fetchUserData()
            controller.fetchSavedLocations()
            
            self.dismiss(animated: true)
            print("DEBUG-SignUpVC: done signUp user \(emailTyped)")
        }
        
        
    }
    
//MARK: - Upload Image
    
    @objc func imageTapped() {
        print("DEBUG-SignupVC: image tapped")
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    
}

//MARK: - Extension for ImagePicker

extension SignupViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //this func gets called once user has just chose a pict
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        print("DEBUG: just finished picking a photo")
        
        guard let selectedImage = info[.editedImage] as? UIImage else {
            print("DEBUG: error setting selectedImage")
            return
        }
        //let's set the picked image equal to the profileImage
        profileImage.image = selectedImage
        
        //let's set the button image to the selected image
        profileImageView.layer.cornerRadius = profileImageView.frame.width/2
        profileImageView.layer.masksToBounds = true
        profileImageView.layer.borderWidth = 2
        profileImageView.layer.borderColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
        profileImageView.image = selectedImage
        
        self.dismiss(animated: true, completion: nil)
    }
}

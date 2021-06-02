//
//  LoginViewController.swift
//  GoodPlaces
//
//  Created by Long Nguyen on 4/29/21.
//

import UIKit
import Firebase
import JGProgressHUD

protocol LoginViewControllerDelegate: class {
    func fetchUserStuff()
}

class LoginViewController: UIViewController {
    
    weak var delegate: LoginViewControllerDelegate?

    private var logoD: CGFloat = 100
    private var viewModel = ViewModelLogin()
    
    //MARK: - Components
    
    private var backgroundImage: UIImageView = {
        let iv = UIImageView()
        iv.image = #imageLiteral(resourceName: "city.jpeg").withRenderingMode(.alwaysOriginal)
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        
        return iv
    }()
    
    private let dismissButton: UIButton = {
        let btn = UIButton()
        btn.setBackgroundImage(UIImage(systemName: "xmark.circle"), for: .normal)
        btn.tintColor = .red
        btn.isUserInteractionEnabled = false
        btn.addTarget(self, action: #selector(dismissLoginVC), for: .touchUpInside)
        
        return btn
    }()
    
    
    private let titleLabel: UILabel = {
        let lb = UILabel()
        lb.text = "GoodPlaces"
        //lb.font = UIFont(name: "Avenir-Light", size: 36)
        lb.font = UIFont.systemFont(ofSize: 40, weight: .regular)
        lb.textColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1).withAlphaComponent(0.8)
        
        return lb
    }()
    
    private let logoIcon: UIImageView = {
        let iv = UIImageView()
//        iv.image = UIImage(systemName: "building.columns")
        iv.image = #imageLiteral(resourceName: "1024gp")
        iv.tintColor = .black
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFit
//        iv.layer.backgroundColor = #colorLiteral(red: 0.9686274529, green: 0.78039217, blue: 0.3450980484, alpha: 1)
        
        return iv
    }()
    
    
    private let emailInputView = AuthTextFieldView(imageIndicator: UIImage(systemName: "envelope"), placeHolderText: "Email please..", secure: false)
    
    private let passwordInputView = AuthTextFieldView(imageIndicator: UIImage(systemName: "lock"), placeHolderText: "Password please..", secure: true)
    
    
    private let logInButton: UIButton = {
        let btn = UIButton(type: .system)
        btn.setHeight(height: 50)
        btn.setTitle("Sign in", for: .normal)
        btn.setTitleColor(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1), for: .normal)
        btn.backgroundColor = #colorLiteral(red: 0.4625613345, green: 0.8433452073, blue: 0.2356247896, alpha: 1)
        btn.isEnabled = false
        btn.alpha = 0.8
        btn.titleLabel?.font = UIFont.systemFont(ofSize: 20, weight: .regular)
        btn.layer.cornerRadius = 16
        btn.layer.borderWidth = 1
        btn.layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1) //we got black here
        btn.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        
        return btn
    }()
    
    private let switchSignUpButton: UIButton = {
        let btn = UIButton(type: .system)
        let textColor: UIColor = #colorLiteral(red: 0.1521535128, green: 0.9202688047, blue: 0.9764705896, alpha: 1)
        let attributedTitle = NSMutableAttributedString (string: "Don't have an account?  ", attributes: [.font: UIFont.systemFont(ofSize: 22), .foregroundColor: textColor])
        
        attributedTitle.append(NSMutableAttributedString(string: "Sign Up", attributes: [.font: UIFont.boldSystemFont(ofSize: 22), .foregroundColor: UIColor.yellow]))
        btn.setAttributedTitle(attributedTitle, for: .normal)
        
        //let's add some action
        btn.addTarget(self, action: #selector(switchToSignUp), for: .touchUpInside)
        
        return btn
    }()
    
    
//MARK: - View Scenes
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        HideKeyBoard()
        configureUI()
        dismissButton.alpha = 0
        formValidation()
        
//        emailInputView.textField.text = "1@gmail.co"
//        passwordInputView.textField.text = "qqqqq"
    }
    
    
//MARK: - Configure UI
    
    func configureUI() {
        //view.backgroundColor = #colorLiteral(red: 0.8873513225, green: 1, blue: 0.6566537536, alpha: 1).withAlphaComponent(0.87)
        view.backgroundColor = #colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1)
        navigationController?.navigationBar.isHidden = true
        
        //backgroundImage
        view.addSubview(backgroundImage)
        backgroundImage.frame = view.bounds
        
        //dismissButton
        view.addSubview(dismissButton)
        dismissButton.anchor(top: view.safeAreaLayoutGuide.topAnchor, left: view.safeAreaLayoutGuide.leftAnchor, paddingTop: 4, paddingLeft: 14)
        dismissButton.setDimensions(height: 32, width: 32)
        
        //titleLabel and logoIcon
        view.addSubview(titleLabel)
        titleLabel.anchor(top: dismissButton.bottomAnchor, paddingTop: 8)
        titleLabel.centerX(inView: view)
        
        view.addSubview(logoIcon)
        logoIcon.anchor(top: titleLabel.bottomAnchor, paddingTop: 14)
        logoIcon.centerX(inView: view)
        logoIcon.setDimensions(height: logoD, width: logoD)
        logoIcon.layer.cornerRadius = logoD/2
        
        //TextView
        let stack  = UIStackView(arrangedSubviews: [emailInputView, passwordInputView, logInButton])
        stack.axis = .vertical
        stack.spacing = 16
        stack.distribution = .fillEqually
        
        view.addSubview(stack)
        stack.anchor(top: logoIcon.bottomAnchor, left: view.leftAnchor, right: view.rightAnchor, paddingTop: 30, paddingLeft: 24, paddingRight: 24)
        
        //signUpButton
        view.addSubview(switchSignUpButton)
        switchSignUpButton.anchor(left: view.leftAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, right: view.rightAnchor, paddingLeft: 24, paddingBottom: 12, paddingRight: 24)
    }
    
    
//MARK: - Actions
    
    @objc func dismissLoginVC() {
        print("DEBUG-fromLoginVC: dismissButton tapped..")
        dismiss(animated: true, completion: nil)
    }

    
    @objc func switchToSignUp() {
        print("DEBUG-fromLoginVC: signUpButton tapped..")
        let vc = SignupViewController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
//MARK: - keyboard
    //let's deal with the keyboard without the use of IQKeyboardManager (tap anywhere to dismiss it)
    func HideKeyBoard() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(DismissKeyboard))
        view.addGestureRecognizer(tap)
    }
    
    @objc func DismissKeyboard() {
        print("DEBUG: dismissing keyboard..")
        view.endEditing(true)
    }
    
//MARK: - checking form
    
    func formValidation() {
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
        
        checkFormStatus() //we have the viewModel all filled up with text
    }
    
    func checkFormStatus () {
        if viewModel.formIsValid {
            //this code is executed when viewModel.formIsValid == true
            logInButton.isEnabled = true
            logInButton.backgroundColor = #colorLiteral(red: 0.4889321203, green: 1, blue: 0.7424639802, alpha: 1)
            logInButton.alpha = 1
        } else {
            logInButton.isEnabled = false
            logInButton.alpha = 0.8
            logInButton.backgroundColor = #colorLiteral(red: 0.4625613345, green: 0.8433452073, blue: 0.2356247896, alpha: 1)
            logInButton.setTitleColor(.black, for: .normal)
        }
    }
    
//MARK: - sign in user
    @objc func signInButtonTapped() {
        print("DEBUG-fromLoginVC: signInButton tapped..")
        //viewModel got filled with data in the "checking form" section
        guard let emailTyped = viewModel.email else { return }
        guard let passwordTyped = viewModel.password else { return }
        
        showLoader(show: true, text: "Logging in", view: view)
        DismissKeyboard()
        
        Auth.auth().signIn(withEmail: emailTyped, password: passwordTyped) { (result, error) in
            
            self.showLoader(show: false, view: self.view)
            
            if let e = error?.localizedDescription {
                print("DEBUG-LoginVC: fail to logIn - \(e)")
                self.alert(error: e, buttonNote: "Try again")
                return
            }
            
            //let's call out the func from HomeVC
            guard let controller = UIApplication.shared.keyWindow?.rootViewController as? HomeViewController else { return }
            controller.fetchingStuff()
            
            print("DEBUG-LoginVC: log in \(emailTyped) successfully")
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    
    
    
    
    
}

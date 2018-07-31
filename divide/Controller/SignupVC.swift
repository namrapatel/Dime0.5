//
//  SignupVC.swift
//  Funder
//
//  Created by Namra Patel on 2017-12-08.
//  Copyright © 2017 Namra Patel. All rights reserved.
//

import UIKit
import EasyPeasy

class SignupVC: UIViewController {
    
    let nameTextField = UnderlineTextField()
    let emailTextField = UnderlineTextField()
    let passwordTextField = UnderlineTextField()
    let signupButton = RoundedButton()
    let logoImageView = UIImageView()
    let loginButton = UIButton()
    let titleLabel = UILabel()
    let errorLabel = UILabel()
    let backButton = UIButton()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        errorLabel.isHidden = true
        let gradientView = GradientView()
        view.addSubview(gradientView)
        gradientView <- [Edges()]
        gradientView.topColor = UI.Colours.gradientTopColour
        gradientView.bottomColor = UI.Colours.gradientBottomColour
        
        setupTitle()
        setupLogo()
        setupNameTextField()
        setupEmailTextField()
        setupPasswordTextField()
        setupLoginButton()
        setupSignupButton()
        setupBackButton()
    }
    
    override func viewDidLayoutSubviews() {
        nameTextField.underlined()
        emailTextField.underlined()
        passwordTextField.underlined()
    }
    
    func setupBackButton() {
        view.addSubview(backButton)
        backButton.setImage(UIImage(named: "left-arrow"), for: .normal)
        backButton.addTarget(self, action: #selector(backPressed(_:)), for: .touchUpInside)
        backButton <- [
            Top(40),
            Left(25),
            Size(45)
        ]
        
    }
    
    func setupTitle() {
        view.addSubview(titleLabel)
        titleLabel.text = "Welcome to"
        titleLabel.font = UI.Font.medium(25)
        titleLabel.textColor = UI.Colours.white
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = .center
        titleLabel <- [Top(50), CenterX()]
    }
    
    func setupLogo() {
        view.addSubview(logoImageView)
        logoImageView.image = UIImage(named: "logo")
        logoImageView <- [
            Width(100),
            Top(10).to(titleLabel),
            CenterX()
        ]
    }
    
    func setupNameTextField() {
        view.addSubview(nameTextField)
        nameTextField.minimumFontSize = 17
        nameTextField.clearButtonMode = .never
        nameTextField.font = UI.Font.regular(15)
        let placeholder = NSMutableAttributedString(string: "Name")
        placeholder.addAttribute(NSAttributedStringKey.foregroundColor, value: UI.Colours.lightGrey, range: NSMakeRange(0, placeholder.length))
        nameTextField.attributedPlaceholder = placeholder
        nameTextField.tintColor = UI.Colours.white
        nameTextField.autocorrectionType = .default
        nameTextField.textColor = UI.Colours.white
        
        let userImageView = UIImageView(image: UIImage(named: "user"))
        userImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        nameTextField.leftViewMode = .always
        nameTextField.leftView = userImageView
        nameTextField <- [
            Top(200),
            Height(30),
            Left(30),
            Right(30)
        ]
    }
    
    func setupEmailTextField() {
        view.addSubview(emailTextField)
        emailTextField.minimumFontSize = 17
        emailTextField.clearButtonMode = .never
        emailTextField.font = UI.Font.regular(15)
        let placeholder = NSMutableAttributedString(string: "Email address")
        placeholder.addAttribute(NSAttributedStringKey.foregroundColor, value: UI.Colours.lightGrey, range: NSMakeRange(0, placeholder.length))
        emailTextField.attributedPlaceholder = placeholder
        emailTextField.tintColor = UI.Colours.white
        emailTextField.autocapitalizationType = .none
        emailTextField.autocorrectionType = .no
        emailTextField.textColor = UI.Colours.white
        emailTextField <- [
            Top(16).to(nameTextField, .bottom),
            Height(30),
            Left(30),
            Right(30)
        ]
    }
    
    func setupPasswordTextField() {
        view.addSubview(passwordTextField)
        passwordTextField.minimumFontSize = 17
        passwordTextField.clearButtonMode = .never
        passwordTextField.font = UI.Font.regular(15)
        let placeholder = NSMutableAttributedString(string: "Password")
        placeholder.addAttribute(NSAttributedStringKey.foregroundColor, value: UI.Colours.lightGrey, range: NSMakeRange(0, placeholder.length))
        passwordTextField.attributedPlaceholder = placeholder
        passwordTextField.tintColor = UI.Colours.white
        passwordTextField.autocorrectionType = .no
        passwordTextField.autocapitalizationType = .none
        passwordTextField.layer.masksToBounds = true
        passwordTextField.textColor = UI.Colours.white
        passwordTextField.isSecureTextEntry = true
        let lockImageView = UIImageView(image: UIImage(named: "lock"))
        lockImageView.frame = CGRect(x: 0, y: 0, width: 20, height: 20)
        passwordTextField.leftViewMode = .always
        passwordTextField.leftView = lockImageView
        passwordTextField <- [
            Top(16).to(emailTextField, .bottom),
            Height(30),
            Left(30),
            Right(30)
        ]
    }
    
    func setupSignupButton() {
        view.addSubview(signupButton)
        signupButton.backgroundColor = UI.Colours.pink
        signupButton.titleLabel?.textColor = UI.Colours.white
        signupButton.titleLabel?.font = UI.Font.demiBold(18)
        signupButton.setTitle("SIGN UP", for: .normal)
        signupButton.cornerRadius = 25
        signupButton.addTarget(self, action: #selector(signUpPressed(_:)), for: .touchUpInside)
        signupButton <- [
            Bottom(15).to(loginButton),
            Left(50),
            Right(50),
            Height(50)
        ]
    }
    
    func setupLoginButton() {
        view.addSubview(loginButton)
        let loginString = NSMutableAttributedString(string: "Have an account? LOG IN")
        loginString.addAttributes([NSAttributedStringKey.foregroundColor: UI.Colours.lightGrey, NSAttributedStringKey.font: UI.Font.regular(15)], range: NSMakeRange(0, loginString.length - 7))
        loginString.addAttributes([NSAttributedStringKey.foregroundColor: UI.Colours.white, NSAttributedStringKey.font: UI.Font.demiBold(15)], range: NSMakeRange(loginString.length - 7, 7))
        loginButton.setAttributedTitle(loginString, for: .normal)
        loginButton.addTarget(self, action: #selector(loginPressed(_:)), for: .touchUpInside)
        loginButton <- [
            Bottom(25),
            CenterX()
        ]
    }
    
    @objc func loginPressed(_ sender: Any) {
        dismissDetail()
    }

    
    @objc func backPressed(_ sender: Any) {
        dismissDetail()
    }
    class MainTabBar {
        
    }
    @objc func signUpPressed(_ sender: Any) {
        if nameTextField.text != "" && emailTextField.text != "" && passwordTextField.text != "" {
//        let tabBar = storyboard?.instantiateViewController(withIdentifier: "MainTabBar")
        if emailTextField.text != nil && passwordTextField.text != nil && nameTextField.text != nil {
        AuthService.instance.registerUser(withEmail: self.emailTextField.text!, andPassword: self.passwordTextField.text!, name: nameTextField.text!, userCreationComplete: { (success, registrationError) in
            if success {
                AuthService.instance.loginUser(withEmail: self.emailTextField.text!, andPassword: self.passwordTextField.text!, loginComplete: { (success, nil) in
                    let storyboard = UIStoryboard(name: "MainTabBar", bundle: nil)
                    let vc = storyboard.instantiateViewController(withIdentifier: "MainTabBar") as UIViewController
                    self.present(vc, animated: true, completion: nil)
                    UIApplication.shared.statusBarStyle = .lightContent
                })
            } else {
                if let error = registrationError?.localizedDescription  {
                print(error)
                    self.errorLabel.isHidden = false
                    if error == "The password must be 6 characters long or more." {
                        self.errorLabel.text = error
                    } else if error == "The email address is badly formatted." {
                        self.errorLabel.text = "Please enter a valid email address."
                    } else if error == "The email address is already in use by another account." {
                        self.errorLabel.text = "This user already has a Funder account. Please log in."
                    }
                }
            }
        })
        }
        } else {
            
        }
    }
    
}

extension SignupVC: UITextFieldDelegate {
    
}

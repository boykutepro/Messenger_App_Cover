//
//  LoginViewController.swift
//  Messenger_Cover_App
//
//  Created by Thien Tung on 6/8/20.
//  Copyright © 2020 Thien Tung. All rights reserved.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit

class LoginViewController: UIViewController {
    
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    } ()
    
    private let logoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo_messenger")
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .clear
        return imageView
    } ()
    
    private let emailField: UITextField = {
        let field = UITextField ()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    } ()
    
    private let passwordField: UITextField = {
        let field = UITextField ()
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 12, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    } ()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Login", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    } ()
    
    private let facebookLoginButton: FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email, public_profile"]
        return button
    } ()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Log In"
        view.backgroundColor = .white
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register", style: .done, target: self, action: #selector(didTapRegister))
        
        addComponent()
        setupButton()
    }
    
    func addComponent() {
        view.addSubview(scrollView)
        scrollView.addSubview(logoImageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
    }
    
    func setupButton() {
        
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        //ScrollView
        scrollView.frame = view.bounds
        
        //Logo
        let size = scrollView.width/9*2
        logoImageView.frame = CGRect(x: (scrollView.width - size)/2,
                                     y: 20,
                                     width: size,
                                     height: size)
        emailField.frame = CGRect(x: 30,
                                  y: logoImageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                     y: emailField.bottom + 10,
                                     width: scrollView.width - 60,
                                     height: 52)
        loginButton.frame = CGRect(x: 30,
                                   y: passwordField.bottom + 10,
                                   width: scrollView.width - 60,
                                   height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                           y: loginButton.bottom + 10,
                                           width: scrollView.width - 60,
                                           height: 52)
        facebookLoginButton.frame.origin.y = loginButton.bottom + 20
        
    }
    
    @objc private func loginButtonTapped () {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text, !email.isEmpty, !password.isEmpty, password.count >= 6 else {
            alertUserLoginError()
            return
        }
        
        //Firebase Login
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password) { [weak self] (authResult, error) in
            guard let strongSelf = self else {
                return
            }
            guard let result = authResult, error == nil else {
                print("Lỗi đăng nhập")
                return
            }
            
            let user = result.user
            print("Đăng nhập thành công: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        }
    }
    
    func alertUserLoginError () {
        let alert = UIAlertController(title: "Opps", message: "Nhập đầy đủ thông tin để đăng nhập", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Quay lại", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        
    }
    
    @objc private func didTapRegister() {
        let registerVC = RegisterViewController()
        registerVC.title = "Creat Accout"
        navigationController?.pushViewController(registerVC, animated: true)
    }
    
}

extension LoginViewController: UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == emailField {
            passwordField.becomeFirstResponder()
        } else if textField == passwordField {
            loginButtonTapped()
        }
        
        return true
    }
}

extension LoginViewController: LoginButtonDelegate{
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // NO OPERATION
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        // Unwrap the token from facebook
        guard let token = result?.token?.tokenString else {
            print("Đăng nhập bằng Facebook thất bại")
            return
        }
        print("Get token: \(token)")
        
        // Make a request object to Facebook to get the email and name for the logged in user
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me",
                                                         parameters: ["fields": "email, name"],
                                                         tokenString: token,
                                                         version: nil,
                                                         httpMethod: .get)
        
        // Excute that request
        facebookRequest.start { (_ , result, error) in
            
            //Get data from facebook
            guard let result = result as? [String: Any], error == nil else {
                    print("Failed to make facebook request")
                    return
            }
            
            print(result)
            
            guard let userName = result["name"] as? String,
                let email = result["email"] as? String else {
                    print("Failed to get data from facebook")
                    return
            }

            // Split the name to get firstName and lastName
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count >= 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            
            //print(firstName, lastName)

            DatabaseManager.shared.userExists(with: email) { (exists) in
                if !exists {
                    DatabaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName, lastName: lastName, emailAddress: email))
                    //print("Add user success")
                }
            }
            
            // Lấy chứng chỉ của facebook để đăng nhập.
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            FirebaseAuth.Auth.auth().signIn(with: credential) { [weak self] (authResult, error) in
                guard let strongSelf = self else {
                    return
                }
                
                guard authResult != nil, error == nil else {
                    // Nếu không có chứng chỉ của FB thì hiển thị error.
                    if let error = error {
                        print("Chưa có chứng chỉ cho phép từ Facebook, mã lỗi: \(error)")
                    }
                    
                    return
                }
                print("Đăng nhập thành công")
                strongSelf.navigationController?.dismiss(animated: true, completion: nil)
            }
        }
    }
}

//
//  ViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/11/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import ProgressHUD

class WelcomeViewController: UIViewController {
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var repeatPasswordTextField: UITextField!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    //Mark: action
    @IBAction func loginTapped(_ sender: Any) {
        if emailTextField.text != "" && passwordTextField.text != "" {
            loginUser()
        }
        else{
            ProgressHUD.showError("email and password required")
        }
    }
    
    @IBAction func registerButtonTapped(_ sender: Any) {
        
        if emailTextField.text != "" && passwordTextField.text != "" && repeatPasswordTextField.text != "" {
            
            if passwordTextField.text == repeatPasswordTextField.text {
                registerUser()
            }
            else{
                ProgressHUD.showError("Passwords don't match")
            }
            
        }
        else{
            ProgressHUD.showError("all fields required")
        }
        
    }

    @IBAction func backgroundTapped(_ sender: Any) {
        dismissKeyboard()
    }
    
    
    
    
    //Mark: helper functions
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func loginUser(){
        dismissKeyboard()
        ProgressHUD.show("login...")
        FUser.loginUserWith(email: emailTextField.text!, password: passwordTextField.text!) { (error) in
            if error != nil {
                ProgressHUD.showError(error?.localizedDescription)
                return
            }
            
            self.goToApp()
        }
    }
    

    
    func registerUser(){
       dismissKeyboard()
        performSegue(withIdentifier: Segue.showRegister.rawValue, sender: self)
    }
    
    
    //MARK: Navigation
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == Segue.showRegister.rawValue {
            let registerVC = segue.destination as! RegisterViewController
            registerVC.email = emailTextField.text!
            registerVC.password = passwordTextField.text!
        }
    }
    
    func goToApp(){
        ProgressHUD.dismiss()
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApp") as! UITabBarController
        self.present(mainView, animated: true){
            ProgressHUD.showSuccess("Login successful")
        }
    }
    
  
    
}

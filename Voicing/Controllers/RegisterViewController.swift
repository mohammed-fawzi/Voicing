//
//  RegisterViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/13/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import ProgressHUD

class RegisterViewController: UIViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var surenameTextField: UITextField!
    @IBOutlet weak var countryTextField: UITextField!
    @IBOutlet weak var CityTextField: UITextField!
    @IBOutlet weak var phoneTextField: UITextField!
    
    var email: String!
    var password: String!
    var avatarImage: UIImage?
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }
    
    @IBAction func doneButtonTapped(_ sender: Any) {
        if  nameTextField.text! != "" &&
            surenameTextField.text! != "" &&
            countryTextField.text! != "" &&
            CityTextField.text! != "" &&
            phoneTextField.text! != "" {
            
                ProgressHUD.show("Registering...")
                FUser.registerUserWith(email: email, password: password, firstName: nameTextField.text!, lastName: surenameTextField.text!) { (error) in
                    if error != nil{
                        ProgressHUD.dismiss()
                        ProgressHUD.showError(error!.localizedDescription)
                        return
                    }
                    self.registerUser()
                }
            
        } else{
            ProgressHUD.showError("all fields are required ")
        }
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    //MARK: helpers
    
    func dismissKeyboard(){
        self.view.endEditing(false)
    }
    
    func registerUser(){
        let fullName = nameTextField.text! + " " + surenameTextField.text!
        var tempDictionary = [kFIRSTNAME: nameTextField.text!,
                              kLASTNAME: surenameTextField.text!,
                              kFULLNAME: fullName,
                              kCITY: CityTextField.text!,
                              kCOUNTRY: countryTextField.text!,
                              kPHONE: phoneTextField.text!] as [String: Any]
        
        if avatarImage == nil {
            imageFromInitials(firstName: nameTextField.text!, lastName: surenameTextField.text!) { (initialsImage) in

                tempDictionary[kAVATAR] = self.convertImageToString(avatar: initialsImage)
            }
            updateUserWith(values: tempDictionary)
            
        } else {
            
            tempDictionary[kAVATAR] = convertImageToString(avatar: avatarImage!)
            updateUserWith(values: tempDictionary)
        }
        
      
        
    }
    
    func convertImageToString(avatar:UIImage) -> String{
        let avatarImageData = avatar.jpegData(compressionQuality: 0.7)
        let avatarImageString = avatarImageData?.base64EncodedString(options: NSData.Base64EncodingOptions(rawValue: 0))
        return avatarImageString!
    }
    
    func updateUserWith(values: [String:Any]){
        updateCurrentUserInFirestore(withValues: values) { (error) in
            if error != nil {
                DispatchQueue.main.async {
                    ProgressHUD.showError(error!.localizedDescription)
                }
                return
            }
            DispatchQueue.main.async {
                ProgressHUD.dismiss()
            
                        }

            self.goToApp()
        }
    }
    
    func goToApp(){        
        let mainView = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MainApp") as! UITabBarController
        self.present(mainView, animated: true){
            ProgressHUD.showSuccess("registration successful")
        }
    }
}

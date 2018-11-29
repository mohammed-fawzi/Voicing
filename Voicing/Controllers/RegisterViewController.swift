//
//  RegisterViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/13/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import ProgressHUD
import Photos

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
    var camera: Camera!
    
    override func viewDidLoad() {
        super.viewDidLoad()
         camera = Camera(delegate: self)
        avatarImageView.isUserInteractionEnabled = true

    }
    
    @IBAction func avatarDidTapped(_ sender: Any) {
        openPhotoLibrary()
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
            
            tempDictionary[kAVATAR] = self.convertImageToString(avatar: avatarImage!)
            updateUserWith(values: tempDictionary)
        }
        
      
        
    }
    
    func convertImageToString(avatar:UIImage) -> String{
        let avatarImageData = avatar.jpegData(compressionQuality: 0.4)
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
    
    
    func openPhotoLibrary(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    // Access is granted by user
                    self.camera.PresentPhotoLibrary(target: self, canEdit: false)
                    
                }
            }
        default:
            print("Error: no access to photo album.")
        }
        
    }
}



extension  RegisterViewController: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if picture != nil {
            
            
            avatarImageView.image = picture!.circleMasked
            avatarImage = picture!
        }
        
        picker.dismiss(animated: true, completion: nil)
    }
    

    
}

extension RegisterViewController: UINavigationControllerDelegate {
    
}

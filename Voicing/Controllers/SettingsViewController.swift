//
//  SettingsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/14/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var showAvatarSwitch: UISwitch!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var versionLabel: UILabel!
    
    var avatarSwitchStatus = true
    var userDefaults = UserDefaults.standard
    var initialLoad: Bool?
    
    let user = FUser.currentUser()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadUserDefaults()

       avatarImageView.image =  imageFromData(pictureData: user!.avatar).circleMasked
        nameLabel.text = user?.fullname
        
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            versionLabel.text = version
        }
        
        tableView.tableFooterView = UIView()
    }

    @IBAction func blockedUserButtonTapped(_ sender: Any) {
    }
    
    @IBAction func chatBackGroundButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cleanCacheButtonTapped(_ sender: Any) {
    }
    
    @IBAction func tellAFriendButtonTapped(_ sender: Any) {
        let text = "lets chat on Voicing \(kAPPURL)"
        
        let objectsToShare: [Any] = [text]
        
        let activityViewController = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
        
        activityViewController.setValue("lets chat on viocing", forKey: "subject")
        // for ipad
        activityViewController.popoverPresentationController?.sourceView = self.view
        
        self.present(activityViewController, animated: true, completion: nil)
        
    }
    
    @IBAction func termsAndConditionsButtonTapped(_ sender: Any) {
    }
    
    @IBAction func AvatarSwitchChangedValue(_ sender: UISwitch) {
        
        avatarSwitchStatus = sender.isOn
        saveUserDefaults()
    }
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.goToWelcome()
            }
        }
    }
    
    
    
    //MARK:- helpers
    func goToWelcome(){
       let welcomeVC =  UIStoryboard.init(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController")
        self.present(welcomeVC, animated: true, completion: nil)
    }
    
    //MARK:- user Defaults
    func saveUserDefaults(){
        userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
        userDefaults.synchronize()
    }
    
    func loadUserDefaults(){
        
        initialLoad = userDefaults.bool(forKey: kFIRSTRUN)
        
        if !initialLoad! {
            userDefaults.set(true, forKey: kFIRSTRUN)
            userDefaults.set(avatarSwitchStatus, forKey: kSHOWAVATAR)
            userDefaults.synchronize()
        }
        avatarSwitchStatus = userDefaults.bool(forKey: kSHOWAVATAR)
        showAvatarSwitch.isOn = avatarSwitchStatus
    }
    
    

}

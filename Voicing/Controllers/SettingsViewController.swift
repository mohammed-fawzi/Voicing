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
    
    let user = FUser.currentUser()
    
    override func viewDidLoad() {
        super.viewDidLoad()
       avatarImageView.image =  imageFromData(pictureData: user!.avatar).circleMasked
        nameLabel.text = user?.fullname
    }

    @IBAction func blockedUserButtonTapped(_ sender: Any) {
    }
    
    @IBAction func chatBackGroundButtonTapped(_ sender: Any) {
    }
    
    @IBAction func cleanCacheButtonTapped(_ sender: Any) {
    }
    
    @IBAction func tellAFriendButtonTapped(_ sender: Any) {
    }
    
    @IBAction func termsAndConditionsButtonTapped(_ sender: Any) {
    }
    
    
    @IBAction func logOutButtonTapped(_ sender: Any) {
        
        FUser.logOutCurrentUser { (success) in
            if success {
                self.goToWelcome()
            }
        }
    }
    
    
    func goToWelcome(){
       let welcomeVC =  UIStoryboard.init(name: "Welcome", bundle: nil).instantiateViewController(withIdentifier: "WelcomeViewController")
        self.present(welcomeVC, animated: true, completion: nil)
    }

}

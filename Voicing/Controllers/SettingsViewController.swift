//
//  SettingsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/14/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

class SettingsViewController: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

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

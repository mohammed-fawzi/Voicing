//
//  BlockedUsersViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 12/11/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import ProgressHUD

class BlockedUsersViewController: UITableViewController {
    
    var blockedUsers: [FUser] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        
        
       
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadBlockedUsers()
    }

    // MARK: - Table view data source

 

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return blockedUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.userCell.rawValue, for: indexPath) as! ContactCell
        cell.delegate = self
        
        cell.generateCellWith(user: blockedUsers[indexPath.row], indexPath: indexPath)
       
        return cell
    }
    

    
    // MARK: - Table view Delegate
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        didTappedAvatar(indexPath: indexPath)
        //performSegue(withIdentifier: Segue.showBlockedUsers.rawValue, sender: self)
    }


}


extension BlockedUsersViewController: ContactCellDelegate {
    func didTappedAvatar(indexPath: IndexPath) {
        
        let vc =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetailVC") as! ContactDetailsViewController
        
        vc.user = blockedUsers[indexPath.row]
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}


extension BlockedUsersViewController {
    
    func loadBlockedUsers(){
        if FUser.currentUser()!.blockedUsers.count > 0 {
            ProgressHUD.show()
            
            getUsersFromFirestore(withIds: FUser.currentUser()!.blockedUsers) { (allBlockedUsers) in
                
                ProgressHUD.dismiss()
                
                self.blockedUsers = allBlockedUsers
                self.tableView.reloadData()
            }
            
        }
        
    }
}

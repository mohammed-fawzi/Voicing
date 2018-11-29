//
//  ContactDetailsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/15/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit

class ContactDetailsViewController: UITableViewController {
    
    //MARK: Outlets
    @IBOutlet weak var avatarImageView: UIImageView!
    @IBOutlet weak var fullNameLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var blockButton: UIButton!
    @IBOutlet weak var callButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    //MARK: variables
    var user: FUser?

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()

    }

    //MARK: Actions

    @IBAction func callButtonTapped(_ sender: Any) {
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        if let user = self.user {
            
            let chatVC = ChatViewController()
            chatVC.titleName = user.fullname
            chatVC.chatRoomID = startPrivateChat(user1: FUser.currentUser()!, user2: user)
            chatVC.membersID = [FUser.currentId(), user.objectId]
            chatVC.membersToPush = [FUser.currentId(), user.objectId]
            chatVC.hidesBottomBarWhenPushed = true
            chatVC.isGroup = false
            navigationController?.pushViewController(chatVC, animated: true)
        }
       
        
    }
    
    @IBAction func blockUserTapped(_ sender: Any) {
        var blockedUsers = FUser.currentUser()!.blockedUsers
        
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            let index = blockedUsers.index(of: user!.objectId)
            blockedUsers.remove(at: index!)
        } else {
            blockedUsers.append(user!.objectId)
        }
        
        updateCurrentUserInFirestore(withValues: [kBLOCKEDUSERID:blockedUsers]) { (error) in
            if error != nil {
                print("error updating user when blocking:  \(error!.localizedDescription)")
                return
            }
            self.updateBlockStatus()
        }
    }
    
    
    //Mark helpers
    func setupUI(){
        navigationItem.largeTitleDisplayMode = .never
        tableView.tableFooterView = UIView()
        if let user = user {
            avatarImageView.image = imageFromData(pictureData: user.avatar).circleMasked
            fullNameLabel.text = user.fullname
            phoneNumberLabel.text = user.phoneNumber
        }
        updateBlockStatus()
    }
    func updateBlockStatus(){
        if FUser.currentUser()!.blockedUsers.contains(user!.objectId) {
            blockButton.setTitle("Unblock User", for: .normal)
            callButton.isEnabled = false
            messageButton.isEnabled = false
        }
        else{
            blockButton.setTitle("Block User", for: .normal)
            callButton.isEnabled = true
            messageButton.isEnabled = true
        }
    }
}

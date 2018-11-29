//
//  ContactsViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/15/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class ContactsViewController: UITableViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    var allUsers:[FUser] = []
    var filterdUsers:[FUser] = []
    var allUsersGroupped =  NSDictionary() as! [String: [FUser]]
    var sectionTitleList: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    
    override func viewWillAppear(_ animated: Bool) {
        navigationItem.hidesSearchBarWhenScrolling = false
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        
        loadUsers(filter: "All")
        
    }
   

    
    @IBAction func segmentedControlChanged(_ sender: UISegmentedControl) {
        
        switch sender.selectedSegmentIndex {
        case 0:
            loadUsers(filter: "All")
        case 1:
            loadUsers(filter: kCOUNTRY)
        case 2:
            loadUsers(filter: kCITY)
        default:
            return
        }
    }
    
  
    
}




// MARK: - Table view data source
extension ContactsViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return 1
        }
        else{
            return sectionTitleList.count
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterdUsers.count
        }
        else{
            let sectionTitle = sectionTitleList[section]
            return allUsersGroupped[sectionTitle]!.count
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.userCell.rawValue , for: indexPath) as! ContactCell
        
        let user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterdUsers[indexPath.row]
        }
        else {
            let sectionTitle = sectionTitleList[indexPath.section]
            user = allUsersGroupped[sectionTitle]![indexPath.row]
        }
        
        cell.generateCellWith(user: user, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
}


// MARK: - Table view delegate
extension ContactsViewController{
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return sectionTitleList[section]
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return sectionTitleList
    }
    
    override func tableView(_ tableView: UITableView, sectionForSectionIndexTitle title: String, at index: Int) -> Int {
        return index
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        let user: FUser
        if searchController.isActive && searchController.searchBar.text != "" {
            user = filterdUsers[indexPath.row]
        }
        else {
            let sectionTitle = sectionTitleList[indexPath.section]
            user = allUsersGroupped[sectionTitle]![indexPath.row]
        }
        
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

//MARK: search Controller
extension ContactsViewController: UISearchResultsUpdating {
    
    func updateSearchResults(for searchController: UISearchController) {
        filterUsersForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    func filterUsersForSearchText(searchText: String, scope: String = "All"){
        filterdUsers = allUsers.filter { (user) -> Bool in
            return user.firstname.lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
}

// MARK: - Helpers
extension ContactsViewController {
    
   func setupUI(){
    // get rid of empthy cells
    tableView.tableFooterView = UIView()
    navigationItem.searchController = searchController
    navigationItem.hidesSearchBarWhenScrolling = true
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    }
    
    func loadUsers(filter:String){
        ProgressHUD.show()
        var query: Query!
        
        switch filter {
        case kCITY:
            query = reference(.User).whereField(kCITY, isEqualTo: FUser.currentUser()!.city).order(by: kFIRSTNAME, descending: false)
        case kCOUNTRY:
            query = reference(.User).whereField(kCOUNTRY, isEqualTo: FUser.currentUser()!.country).order(by: kFIRSTNAME, descending: false)
        default:
            query = reference(.User).order(by: kFIRSTNAME, descending: false)
        }
        
        query.getDocuments { (snapShot, error) in
            
            self.allUsers = []
            self.allUsersGroupped = [:]
            self.sectionTitleList = []
            
            if error != nil {
                ProgressHUD.dismiss()
                print(error!.localizedDescription)
                self.tableView.reloadData()
                return
            }
            
            guard let snapShot = snapShot else {ProgressHUD.dismiss(); return}
            
            if !snapShot.isEmpty {
                
                for document in snapShot.documents {
                    let user  = FUser(dictionary: document.data() as NSDictionary)
                    if user.objectId != FUser.currentId() {
                        self.allUsers.append(user)
                    }
                }
                
                
            }
            // split to groups
            self.splitContactsIntoGroups()
            DispatchQueue.main.async {
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
            
        }
   
    }
    
    func splitContactsIntoGroups(){
        for user in allUsers {
            let firstChar = ("\(user.firstname.first!)").uppercased()
            
            if allUsersGroupped[firstChar] == nil {
                allUsersGroupped[firstChar] = []
            }
            allUsersGroupped[firstChar]!.append(user)
            }
        
        allUsersGroupped.keys.forEach { (key) in
            sectionTitleList.append(key)
            sectionTitleList.sort()
        }
    }
    
    
}

// show contact details when clicked the avatar image
extension ContactsViewController: ContactCellDelegate {
    func didTappedAvatar(indexPath: IndexPath) {
        
      let vc =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetailVC") as! ContactDetailsViewController
        
        if searchController.isActive && searchController.searchBar.text != "" {
            vc.user = filterdUsers[indexPath.row]
        }
        else{
            let sectionTitle = sectionTitleList[indexPath.section]
            vc.user = allUsersGroupped[sectionTitle]![indexPath.row]
        }
        
        navigationController?.pushViewController(vc, animated: true)
    }
}


//
//  UsersViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/15/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import Firebase
import ProgressHUD

class UsersViewController: UITableViewController {
    
    @IBOutlet weak var topContainerView: UIView!
    @IBOutlet weak var segmentControl: UISegmentedControl!
    
    
    var allUsers:[FUser] = []
    var filterdUsers:[FUser] = []
    var allUsersGroupped =  NSDictionary() as! [String: [FUser]]
    var sectionTitleList: [String] = []
    
    let searchController = UISearchController(searchResultsController: nil)
    

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Contacts"
        // get rid of empthy cells 
        tableView.tableFooterView = UIView()
        
        loadUsers(filter: "All")
        
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return allUsers.count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.userCell.rawValue , for: indexPath) as! UserCell

        // Configure the cell...
        cell.generateCellWith(user: allUsers[indexPath.row], indexPath: indexPath)

        return cell
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

//MARK: search Controller
extension UsersViewController: UISearchResultsUpdating {
    
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


extension UsersViewController {
    
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
                print("errorrrrrrrrrrr")
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
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
                ProgressHUD.dismiss()
            }
            
        }
   
    }
    
    
}

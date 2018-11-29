//
//  RecentViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/18/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import FirebaseFirestore

class RecentViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var recentChats: [NSDictionary] = []
    var filterdRecentChats: [NSDictionary] = []
    var recentListener: ListenerRegistration!
    let searchController = UISearchController(searchResultsController: nil)
   
    
    override func viewWillAppear(_ animated: Bool) {
        loadData()
        navigationItem.hidesSearchBarWhenScrolling = false

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        recentListener.remove()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        
    }
    
    
    
    @IBAction func newGroupButtonTapped(_ sender: Any) {
    }
    
   
}

//MARK: tableView Data Source
extension RecentViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        if searchController.isActive && searchController.searchBar.text != "" {
            return filterdRecentChats.count
        }
        else{
            return recentChats.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: Cell.recentCell.rawValue , for: indexPath) as! RecentCell
       
        cell.delegate = self
        
        let recent = getRecentChat(indexPath: indexPath)
        
        cell.generateCell(recentChat: recent, indexPath: indexPath)
        return cell
    }
    
    
}

//MARK: tableView Delegate
extension RecentViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
       
        let recent = getRecentChat(indexPath: indexPath)
        
        var muteTitle = "Unmute"
        var mute = false
        
        if (recent[kMEMBERSTOPUSH] as! [String]).contains(FUser.currentId()) {
            muteTitle = "Mute"
            mute = true
        }
        
        let deleteAction = UITableViewRowAction(style: .default, title: "Delete") { (action, indexPath) in
            
            deleteRecentChat(recentChatDictionary: recent)
            tableView.reloadData()
        }
        let muteAction = UITableViewRowAction(style: .default, title: muteTitle) { (action, indexPath) in
            print(indexPath)
        }
        
        muteAction.backgroundColor = #colorLiteral(red: 0.009609803535, green: 0.477657332, blue: 1, alpha: 1)
        
        return [deleteAction,muteAction]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
       
        tableView.deselectRow(at: indexPath, animated: true)
        
        let recent = getRecentChat(indexPath: indexPath)
        
        // restart recent chat
        restartRecentChat(recent: recent)
        
        // show chat view
        let chatVC = ChatViewController()
        chatVC.titleName = (recent[kWITHUSERFULLNAME] as? String)!
        chatVC.chatRoomID = (recent[kCHATROOMID] as? String)!
        chatVC.membersID = (recent[kMEMBERS] as? [String])!
        chatVC.membersToPush = (recent[kMEMBERSTOPUSH] as? [String])!
        chatVC.hidesBottomBarWhenPushed = true
        chatVC.isGroup = false
        navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    
}


//MARK: Recent Cell Delegate
// when tapping user avatar image present contact Details for the user
extension RecentViewController: RecentCellDelegate {
    func didTappedAvatar(indexPath: IndexPath) {
        
        let recent = getRecentChat(indexPath: indexPath)
        
        if recent[kTYPE] as! String == kPRIVATE {
            reference(.User).document(recent[kWITHUSERUSERID] as! String).getDocument { (snapShot, error) in
                
                guard let snapShot = snapShot else {return}
                
                if snapShot.exists {
                    let userDictionary = snapShot.data()! as NSDictionary
                    let user = FUser(dictionary: userDictionary)
                    self.showContactDetails(user: user)
                }
            }
        }
    }
    
    func showContactDetails(user: FUser) {
      let VC =  UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetailVC") as! ContactDetailsViewController
        
        VC.user = user
        
        navigationController?.pushViewController(VC, animated: true)
        
    }
}

//MARK: Search Controller delegate
extension RecentViewController: UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterUsersForSearchText(searchText: searchController.searchBar.text!)
    }
    
    
    func filterUsersForSearchText(searchText: String, scope: String = "All"){
        filterdRecentChats = recentChats.filter { (recentChat) -> Bool in
            return (recentChat[kWITHUSERFULLNAME] as! String).lowercased().contains(searchText.lowercased())
        }
        
        tableView.reloadData()
    }
    
    
}

//MARK: helpers
extension RecentViewController {
    func loadData(){
       
        recentListener = reference(.Recent).whereField(kUSERID, isEqualTo: FUser.currentId()).addSnapshotListener({ (snapShot, error) in
            
            guard let snapShot = snapShot else{return}
            
            self.recentChats = []
            
            if !snapShot.isEmpty{
                
                let  sortedRecentChats = ((dictionaryFromSnapshots(snapshots: snapShot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: false)]) as! [NSDictionary]
                
                
                for recent in sortedRecentChats {
                    
                    if recent[kLASTMESSAGE] as! String != "" && recent[kCHATROOMID] != nil && recent[kRECENTID] != nil {
                        self.recentChats.append(recent)
                    }
                }
                
                self.tableView.reloadData()
            }
            
        })
    }
    
    
    func setupUI(){
        tableView.tableFooterView = UIView()
        navigationItem.searchController = searchController
        navigationItem.hidesSearchBarWhenScrolling = true
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = false
        definesPresentationContext = true
    }
    
    // return the right recent chat if search is enabled or not
    func getRecentChat(indexPath: IndexPath) -> NSDictionary {
        
        var recent: NSDictionary!
        
        if searchController.isActive && searchController.searchBar.text != "" {
            recent = filterdRecentChats[indexPath.row]
        }
        else{
            recent = recentChats[indexPath.row]
        }
        
        return recent
    }
    
}

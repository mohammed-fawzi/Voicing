//
//  Recent.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/17/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation

func startPrivateChat(user1: FUser, user2: FUser) -> String {
    
    let user1ID = user1.objectId
    let user2ID = user2.objectId
    var chatRoomID = ""
    
    //  generate same chat room ID for the two users regardless who starts the chat
    let value = user1ID.compare(user2ID).rawValue
    if value < 0 {
        chatRoomID = user1ID + user2ID
    }else{
        chatRoomID = user2ID + user1ID
    }
    
    let members = [user1ID,user2ID]
    
    // create recent Chat
    createRecent(membersID: members, chatRoomID: chatRoomID, withUserUserName: "", type: kPRIVATE, users: [user1,user2], avatarOfGroup: nil)
    
    return chatRoomID
}

func createRecent(membersID: [String],chatRoomID: String,withUserUserName: String, type:String, users: [FUser]?, avatarOfGroup: String? ){
    var tempMembersID = membersID
    
    // if there is an existing recent don't create a new recent for it's associated user
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapShot, error) in
        guard let snapShot = snapShot else {return}
        
        
        if !snapShot.isEmpty {
            for recent in snapShot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if let currentUserID = currentRecent[kUSERID] {
                    
                    if tempMembersID.contains(currentUserID as! String) {
                        
                        let index =  tempMembersID.index(of: currentUserID as! String)!
                        tempMembersID.remove(at: index )
                    }
                }
            }
        }
        
        // create recent for remaining members
        
        for userID in tempMembersID {
            createRecentItem(userID: userID, chatRoomID: chatRoomID, membersID: membersID, withUserUserName: withUserUserName, type: type, users: users, avatarOfGroup: avatarOfGroup)
        }
        
    }
    
}


func createRecentItem(userID:String, chatRoomID:String, membersID:[String], withUserUserName:String, type:String, users:[FUser]?, avatarOfGroup: String? ){
    
    let ref = reference(.Recent).document()
    let recentID = ref.documentID
    
    let date = dateFormatter().string(from: Date())
    var recent:[String:Any]!
    
    if type == kPRIVATE {
        // create for private chat
        var withUser: FUser?
        if users != nil &&  users!.count > 0 {
            if userID == FUser.currentId() {
                // create for current user
                withUser = users!.last
            }else {
                // create for the other user
                withUser = users!.first
            }
        }
        
        recent = [kRECENTID: recentID,
                  kUSERID:userID,
                  kCHATROOMID: chatRoomID,
                  kMEMBERS: membersID,
                  kMEMBERSTOPUSH: membersID,
                  kWITHUSERFULLNAME: withUser!.fullname,
                  kWITHUSERUSERID: withUser!.objectId,
                  kLASTMESSAGE:"",
                  kCOUNTER: 0 ,
                  kDATE: date,
                  kTYPE:type,
                  kAVATAR: withUser!.avatar ] as [String:Any]
        
    }else {
        // create for group Chat
        if avatarOfGroup != nil {
            
            recent = [kRECENTID: recentID,
                      kUSERID:userID,
                      kCHATROOMID: chatRoomID,
                      kMEMBERS: membersID,
                      kMEMBERSTOPUSH: membersID,
                      kWITHUSERFULLNAME: withUserUserName,
                      kLASTMESSAGE:"",
                      kCOUNTER: 0 ,
                      kDATE: date,
                      kTYPE:type,
                      kAVATAR: avatarOfGroup! ] as [String:Any]
        }
        
    }
    
    // save to firestore
    ref.setData(recent)
}


// delete recent chat
func deleteRecentChat(recentChatDictionary: NSDictionary){
    
    if let recentID = recentChatDictionary[kRECENTID] {
        reference(.Recent).document(recentID as! String).delete()
    }
}


// restart Chat
func restartRecentChat(recent: NSDictionary){
    
    if recent[kTYPE] as! String == kPRIVATE {
        
        createRecent(membersID: recent[kMEMBERSTOPUSH] as! [String],
                     chatRoomID: recent[kCHATROOMID] as! String,
                     withUserUserName: "",
                     type: kPRIVATE,
                     users: [FUser.currentUser()!],
                     avatarOfGroup: nil)
        
    }
    
    else if recent[kTYPE] as! String == kGROUP {
        
        createRecent(membersID: recent[kMEMBERSTOPUSH] as! [String],
                     chatRoomID: recent[kCHATROOMID] as! String,
                     withUserUserName: "",
                     type: kGROUP,
                     users: nil ,
                     avatarOfGroup: recent[kAVATAR] as? String)
        
    }
    
    
}

// clear recent counter
func clearRecentCounter(chatRoomID: String){
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapShot, error) in
        
        guard let snapShot = snapShot else {return}
        
        if !snapShot.isEmpty {
            
            for recent in snapShot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
                if currentRecent[kUSERID] as! String == FUser.currentId() {
                    
                    reference(.Recent).document(currentRecent[kRECENTID] as! String).updateData([kCOUNTER : 0])
                }
            }
        }
    }
}


// update Recent

func updateRecent(chatRoomID: String, lastMessage: String){
    
    reference(.Recent).whereField(kCHATROOMID, isEqualTo: chatRoomID).getDocuments { (snapShot, error) in
        
        guard let snapShot = snapShot else {return}
        
        if !snapShot.isEmpty {
            
            for recent in snapShot.documents {
                
                let currentRecent = recent.data() as NSDictionary
                
               updateRecentItem(recent: currentRecent, lastMessage: lastMessage)
            }
        }
    }
}

func updateRecentItem(recent: NSDictionary, lastMessage: String){
    
    let date = dateFormatter().string(from: Date())
    
    var counter = recent[kCOUNTER] as! Int
    
    if recent[kUSERID] as? String != FUser.currentId() {
        counter += 1
    }
    
    let values = [kLASTMESSAGE: lastMessage, kCOUNTER: counter , kDATE: date] as [String: Any]
    
    reference(.Recent).document(recent[kRECENTID] as! String).updateData(values)
}

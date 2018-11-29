//
//  OutgoingMessage.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/19/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation


class OutGoingMessage{
    
    
    let messageDictionary: NSMutableDictionary
    
    // text Message
    init(message: String, senderID: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message,
                                                          senderID,
                                                          senderName,
                                                          dateFormatter().string(from: date),
                                                          status,
                                                          type],
                                                forKeys: [kMESSAGE as NSCopying,
                                                          kSENDERID as NSCopying,
                                                          kSENDERNAME as NSCopying,
                                                          kDATE as NSCopying,
                                                          kSTATUS as NSCopying,
                                                          kTYPE as NSCopying])
    
    }
    
    // picture Message
    init(message: String, pictureLink: String, senderID: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message,
                                                          pictureLink,
                                                          senderID,
                                                          senderName,
                                                          dateFormatter().string(from: date),
                                                          status,
                                                          type],
                                                forKeys: [kMESSAGE as NSCopying,
                                                          kPICTURE as NSCopying,
                                                          kSENDERID as NSCopying,
                                                          kSENDERNAME as NSCopying,
                                                          kDATE as NSCopying,
                                                          kSTATUS as NSCopying,
                                                          kTYPE as NSCopying])
    
    
    }
    
    // audio message
    init(message: String, audioLink: String, senderID: String, senderName: String, date: Date, status: String, type: String) {
        
        messageDictionary = NSMutableDictionary(objects: [message,
                                                          audioLink,
                                                          senderID,
                                                          senderName,
                                                          dateFormatter().string(from: date),
                                                          status,
                                                          type],
                                                forKeys: [kMESSAGE as NSCopying,
                                                          kAUDIO as NSCopying,
                                                          kSENDERID as NSCopying,
                                                          kSENDERNAME as NSCopying,
                                                          kDATE as NSCopying,
                                                          kSTATUS as NSCopying,
                                                          kTYPE as NSCopying])
        
        
    }
    
    func saveMessage(messageDictionary: NSMutableDictionary, chatRoomID: String, membersID: [String],
                     membersToPush: [String]){
        
        let messageID = UUID().uuidString
        messageDictionary[kMESSAGEID] = messageID
        
        for memberID in membersID {
            reference(.Message).document(memberID).collection(chatRoomID).document(messageID).setData(messageDictionary as! [String:Any])
        }
        
        //update recent chat
        updateRecent(chatRoomID: chatRoomID, lastMessage: messageDictionary[kMESSAGE] as! String)
        //send push notification
    }
    
    
}

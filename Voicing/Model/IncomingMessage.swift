//
//  IncomingMessage.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/19/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation
import JSQMessagesViewController

class IncomingMessage {
    
    var collectionView: JSQMessagesCollectionView?
    
    init(collectionView: JSQMessagesCollectionView) {
        self.collectionView = collectionView
    }
    
    func createMessage(messageDictionary: NSDictionary, chatRoomID: String) -> JSQMessage? {
        let type = messageDictionary[kTYPE] as? String
        
        var message: JSQMessage?
        switch type {
        case kTEXT:
            message = createTextMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomID)
        case kPICTURE:
            message = createPictureMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomID)
        case kVIDEO:
            print("video")
        case kAUDIO:
            message = createAudioMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomID)
        case kLOCATION:
            print("location")
        default:
            print("unknown")

        }
        
        if message != nil {
            return message
        }
        return nil
    }
    
    // text message
    func createTextMessage(messageDictionary: NSDictionary, chatRoomID: String) -> JSQMessage {
        let senderID = messageDictionary[kSENDERID] as! String
        let senderName = messageDictionary[kSENDERNAME] as! String
        let text = messageDictionary[kMESSAGE] as! String
        let date = checkDate(messageDictionary: messageDictionary)
       
        
        return JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, text: text)
    }
    
    
    func checkDate(messageDictionary: NSDictionary) -> Date{
        var date: Date!
        if let createdAt = messageDictionary[kDATE] {
            if (createdAt as! String).count != 14 {
                date = Date()
            }else{
                date = dateFormatter().date(from: createdAt as! String)
            }
        }else {
            date = Date()
        }
        
        return date
    }
    
    // picture message
    
    func createPictureMessage(messageDictionary: NSDictionary, chatRoomID: String) -> JSQMessage{
        
        let senderID = messageDictionary[kSENDERID] as! String
        let senderName = messageDictionary[kSENDERNAME] as! String
        let date = checkDate(messageDictionary: messageDictionary)
        
        let mediaItem = PhotoMediaItem(image: nil)
        mediaItem?.appliesMediaViewMaskAsOutgoing = (senderID == FUser.currentId())
        
        downlaodImage(imageUrl: messageDictionary[kPICTURE] as! String) { (image) in
            
            if image != nil {
                mediaItem?.image = image
                self.collectionView?.reloadData()
            }
        }
        
        return JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, media: mediaItem)
    }
    
    // audio Message
    
    
    func createAudioMessage(messageDictionary: NSDictionary, chatRoomID: String) -> JSQMessage{
        
        let senderID = messageDictionary[kSENDERID] as! String
        let senderName = messageDictionary[kSENDERNAME] as! String
        let date = checkDate(messageDictionary: messageDictionary)
        
        let audioItem = JSQAudioMediaItem(data: nil)
        audioItem.appliesMediaViewMaskAsOutgoing = (senderID == FUser.currentId())
        
        downlaodAudio(audioUrl: messageDictionary[kAUDIO] as! String) { (data) in
            if data != nil {
                audioItem.audioData = data
                self.collectionView?.reloadData()
            }
        }
        
        return JSQMessage(senderId: senderID, senderDisplayName: senderName, date: date, media: audioItem)
    }
    
    
    
    
    
    
    
    
    
}

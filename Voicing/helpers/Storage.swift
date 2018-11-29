//
//  Storage.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/28/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import Foundation
import FirebaseStorage
import Firebase
import MBProgressHUD
import AVFoundation

let storage = Storage.storage()

func uploadImage(image: UIImage, chatRoomID: String, view: UIView, completion: @escaping (_ imageLink: String?) -> Void ){
    
    let progress = MBProgressHUD.showAdded(to: view, animated: true)
    progress.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let photoFileName = "PictureMessages/" + FUser.currentId() + "/" + chatRoomID + "/" + dateString + ".jpg"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(photoFileName)
    
    let imageData = image.jpegData(compressionQuality: 0.7)
    
    var task: StorageUploadTask!
    
        task = storageRef.putData(imageData!, metadata: nil) { (metaData, error) in
        
            task.removeAllObservers()
            progress.hide(animated: true)
            
            if error != nil {
                print("error while uploading image: \(error!.localizedDescription) ")
                return
            }
            
            storageRef.downloadURL(completion: { (url, error) in
                
                guard let downloadUrl = url else {
                    completion(nil)
                    return
                }
                
                completion(downloadUrl.absoluteString)
            })
            
            
    }
    
    task.observe(StorageTaskStatus.progress) { (snapShot) in
        
        progress.progress = Float((snapShot.progress?.completedUnitCount)!) / Float((snapShot.progress?.totalUnitCount)!)
    }
    
    
}


func downlaodImage(imageUrl: String,  completion: @escaping (_ image: UIImage?) -> Void){
    
    let imageURL = NSURL(string: imageUrl)
    //let imageFileName = (imageUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    let downloadQueue = DispatchQueue(label: "imageDownloadQueue")
    downloadQueue.async {
        let data = NSData(contentsOf: imageURL! as URL)
        
        if data != nil {
            
            let image = UIImage(data: data! as Data)
            
            DispatchQueue.main.async {
                completion(image)
            }
        }else{
            
            DispatchQueue.main.async {
                print("no image in database")
                completion(nil)
            }
        }
    }
}


//MARK:- audio

func uploadAudio(audioPath: String, chatRoomID: String, view: UIView, completion: @escaping (_ audioLink: String?) -> Void ){
    
    let progress = MBProgressHUD.showAdded(to: view, animated: true)
    progress.mode = .determinateHorizontalBar
    
    let dateString = dateFormatter().string(from: Date())
    
    let audioFileName = "AuidoMessages/" + FUser.currentId() + "/" + chatRoomID + "/" + dateString + ".m4a"
    let storageRef = storage.reference(forURL: kFILEREFERENCE).child(audioFileName)
    
    let audioData = NSData(contentsOfFile: audioPath)
    
    var task: StorageUploadTask!
    
    task = storageRef.putData(audioData! as Data, metadata: nil) { (metaData, error) in
        
        task.removeAllObservers()
        progress.hide(animated: true)
        
        if error != nil {
            print("error while uploading audio: \(error!.localizedDescription) ")
            return
        }
        
        storageRef.downloadURL(completion: { (url, error) in
            
            guard let downloadUrl = url else {
                completion(nil)
                return
            }
            
            completion(downloadUrl.absoluteString)
        })
        
        
    }
    
    task.observe(StorageTaskStatus.progress) { (snapShot) in
        
        progress.progress = Float((snapShot.progress?.completedUnitCount)!) / Float((snapShot.progress?.totalUnitCount)!)
    }
    
}


func downlaodAudio(audioUrl: String,  completion: @escaping (_ audioPath: Data?) -> Void){
    
    let audioURL = NSURL(string: audioUrl)
    //let audioFileName = (audioUrl.components(separatedBy: "%").last!).components(separatedBy: "?").first!
    
    let downloadQueue = DispatchQueue(label: "audioDownloadQueue")
    downloadQueue.async {
        let data = NSData(contentsOf: audioURL! as URL)
        
        if data != nil {
            
            let audio = NSData(data: data! as Data)
            
            DispatchQueue.main.async {
                completion(audio as Data)
            }
        }else{
            
            DispatchQueue.main.async {
                print("no audio in database")
                completion(nil)
            }
        }
    }
}



//
//  ChatViewController.swift
//  Voicing
//
//  Created by mohamed fawzy on 11/19/18.
//  Copyright © 2018 mohamed fawzy. All rights reserved.
//

import UIKit
import JSQMessagesViewController
import ProgressHUD
import IQAudioRecorderController
import IDMPhotoBrowser
import AVFoundation
import AVKit
import FirebaseFirestore
import Photos

class ChatViewController: JSQMessagesViewController {
    
    //MARK: *****listerns*****
    var chatListener: ListenerRegistration?
    var typeingListener: ListenerRegistration?
    var updatingListener: ListenerRegistration?
    
    //MARK: *****Flags*****
    var loadOlderMessages: Bool = false
    var initialLoadComplete: Bool = false
    var isGroup: Bool!
    
    //MARK: *****Arrays*****
    var displayMessages: [JSQMessage] = []
    var dictionaryMessages: [NSDictionary] = []
    var loadedMessages: [NSDictionary] = []
    var allPictureMessages: [String] = []
    
    //MARK: *****Counters*****
    var maxMessagesNumber: Int = 0
    var minMessagesNumber: Int = 0
    var displayedMessagesCount: Int = 0
    
    //MARK: *****From recentViewController*****
    var titleName: String!
    var chatRoomID: String!
    var membersID: [String]!
    var membersToPush: [String]!
    var group: NSDictionary?
    var withUsers: [FUser] = []
    
    
    //MARK: *****variables*****
    let appDelegate = UIApplication.shared.delegate as! AppDelegate
    var currentUser: FUser? = FUser.currentUser()
    let legitTypes: [String] = [kTEXT,kPICTURE,kVIDEO,kLOCATION,kAUDIO]
    var outGoingBubble = JSQMessagesBubbleImageFactory()?.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    var inComingBubble = JSQMessagesBubbleImageFactory()?.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    
    var camera: Camera!
    

    //MARK: ***** Avatar variables*****
    var jsqAvatarDictionary: NSMutableDictionary?
    var avatarImageDictionary: NSMutableDictionary?
    var showAvatar = true
    var firstLoad:Bool?
    
    //MARK: *****Header variables*****
    let leftBarButtonView: UIView =  {
        return UIView(frame: CGRect(x: 0, y: 0, width: 200, height: 44 ))
    }()
    
    let avatarButton: UIButton = {
        return UIButton(frame: CGRect(x: 0, y: 10, width: 30, height: 30))
    }()
    
    let titleLabel: UILabel = {
       let title = UILabel(frame: CGRect(x: 35, y: 10, width: 140, height: 15))
        title.textAlignment = .left
        title.font = UIFont(name: title.font.fontName , size: 13)
        
        return title
    }()
    
    let subTitleLabel: UILabel = {
        let subTitle = UILabel(frame: CGRect(x: 35, y: 25, width: 140, height: 15))
        subTitle.textAlignment = .left
        subTitle.font = UIFont(name: subTitle.font.fontName , size: 10)
        
        return subTitle
    }()
    
    
    //MARK:- view controller lifecylce

    override func viewDidLayoutSubviews() {
        perform(Selector(("jsq_updateCollectionViewInsets")))
    }
    
    override func viewWillAppear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomID)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        clearRecentCounter(chatRoomID: chatRoomID)
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
        self.senderId = FUser.currentId()
        self.senderDisplayName = FUser.currentUser()!.firstname
        
        jsqAvatarDictionary = [:]
        
        createHeaderView()
        loadMessage()
        getAvatarImages()
        //fix for iphone x
        let constraint = perform(Selector(("toolbarBottomLayoutGuide")))?.takeUnretainedValue() as! NSLayoutConstraint
        constraint.priority = UILayoutPriority(rawValue: 1000)
        self.inputToolbar.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor).isActive = true
        
        // change send button to mic
        self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named: "mic"), for: .normal)
        self.inputToolbar.contentView.rightBarButtonItem.setTitle("", for: .normal)
    
    }
    

}











//MARK:- Data Source
extension ChatViewController{
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return displayMessages.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        
        let message = displayMessages[indexPath.row]
        
        if isIncomingMessage(message: message) {
            cell.textView?.textColor = .black
        }else {
            cell.textView?.textColor = .white
        }
        
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return displayMessages[indexPath.row]
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = displayMessages[indexPath.row]
        
        if isIncomingMessage(message: message) {
            return inComingBubble
        }else {
             return outGoingBubble
        }
    }
    
    // show time stapm
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellTopLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.item % 3 == 0 {
            let message = displayMessages[indexPath.row]
           return JSQMessagesTimestampFormatter.shared()?.attributedTimestamp(for: message.date)
            
        }
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellTopLabelAt indexPath: IndexPath!) -> CGFloat {
        
        if indexPath.item % 3 == 0 {
            
            return kJSQMessagesCollectionViewCellLabelHeightDefault
            
        }
        return 0.0
    }
    
    // show delivered, read bottom label
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForCellBottomLabelAt indexPath: IndexPath!) -> NSAttributedString! {
        
        if indexPath.row == (displayMessages.count - 1) {
            let message = dictionaryMessages[indexPath.row]
            let status: NSAttributedString!
            let attributedStringColor = [NSAttributedString.Key.foregroundColor: UIColor.darkGray]
            
            switch message[kSTATUS] as! String {
                
            case kDELIVERED:
                status = NSAttributedString(string: kDELIVERED, attributes: attributedStringColor)
                
            case kREAD:
                let read = "Read" + " " + readTimeFrom(dateString: message[kDATE] as! String)
                    status = NSAttributedString(string: read, attributes: attributedStringColor)
                
            default:
                status = NSAttributedString(string: "")
            }
            
            return status
            
        }else {
            return NSAttributedString(string: "")
        }
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForCellBottomLabelAt indexPath: IndexPath!) -> CGFloat {
        let message = displayMessages[indexPath.row]
        if message.senderId == currentUser!.objectId && indexPath.row == (displayMessages.count - 1) {
            return kJSQMessagesCollectionViewCellLabelHeightDefault
        }
        return 0.0
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, header headerView: JSQMessagesLoadEarlierHeaderView!, didTapLoadEarlierMessagesButton sender: UIButton!) {
        //TODO: load more messages
        loadMoreMessages(minNumber: minMessagesNumber, maxNumber: maxMessagesNumber)
        self.collectionView.reloadData()
    }
    
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        
        let message = displayMessages[indexPath.row]
        
        var avatar: JSQMessageAvatarImageDataSource
        
        if let temAvatar = jsqAvatarDictionary!.object(forKey: message.senderId) {
            avatar = temAvatar as! JSQMessageAvatarImageDataSource
        } else {
            avatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        }
        
        return avatar
    }
    
}











//MARK:- Delegate
extension ChatViewController {
    override func didPressAccessoryButton(_ sender: UIButton!) {
         camera = Camera(delegate: self)

        createAccessoryActionSheet()
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        
        if text != "" {
            sendTextMessage(text: text, date: date)
            updateSendButton(isSend: false)
            
        }
        // audio
        else {
            let audioRecorderVC = AudioRecorderViewController(delegate: self)
            audioRecorderVC.presentAudioRcorderViewController(tareget: self)
        }
    }
    
    override func textViewDidChange(_ textView: UITextView) {
        if textView.text != "" {
            updateSendButton(isSend: true)
        }else {
            updateSendButton(isSend: false)

        }
    }
}





//MARK:- image picker controller delegate
extension ChatViewController: UIImagePickerControllerDelegate {
    
    @objc  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let video = info[UIImagePickerController.InfoKey.mediaURL] as? NSURL
        let picture = info[UIImagePickerController.InfoKey.originalImage] as? UIImage
        
        if video != nil {
            sendVideoMessage(video: video, date: Date())
        }
        
        if picture != nil {
            print("image ............................")
            
            sendPhotoMessage(image: picture!, date: Date())
        }
        
        picker.dismiss(animated: true, completion: nil)
        
    }
}

//MARK:- navigation controller delegate
extension ChatViewController: UINavigationControllerDelegate {
    
}


//MARK:- IQaudio recorder delegate
extension ChatViewController: IQAudioRecorderViewControllerDelegate {
    func audioRecorderController(_ controller: IQAudioRecorderViewController, didFinishWithAudioAtPath filePath: String) {
        
        controller.dismiss(animated: true, completion: nil)
        self.sendAudioMessage(audio: filePath, date: Date())
    }
    
    func audioRecorderControllerDidCancel(_ controller: IQAudioRecorderViewController) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    
}




//MARK:- Helpers
extension ChatViewController {
    
    
    func createHeaderView(){
        leftBarButtonView.addSubview(avatarButton)
        leftBarButtonView.addSubview(titleLabel)
        leftBarButtonView.addSubview(subTitleLabel)
        
       
        let leftBarButtonItem = UIBarButtonItem(customView: leftBarButtonView)
        let infoButton = UIBarButtonItem(image: UIImage(named: "info"), style: .plain, target: self, action: #selector(self.infoButtonTapped))
        let callButton = UIBarButtonItem(image: UIImage(named: "call"), style: .plain, target: self, action: #selector(self.callButtonTapped))
        
        let rightBarButtonItems = [infoButton,callButton]
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = leftBarButtonItem
        self.navigationItem.rightBarButtonItems = rightBarButtonItems
        
        
        if isGroup! {
            avatarButton.addTarget(self, action: #selector(self.showGroup), for: .touchUpInside)
        }else{
            avatarButton.addTarget(self, action: #selector(self.showContactDetails), for: .touchUpInside)
        }
        
        getUsersFromFirestore(withIds: membersID) { (users) in
            self.withUsers = users
            
            if !self.isGroup! {
                // update user info
                self.setHeaderForPrivateChat()
            }
        }
        
    }
    
    func setHeaderForPrivateChat(){
        let withUser = withUsers.first!
        
        let avatar = imageFromData(pictureData: withUser.avatar).circleMasked
        avatarButton.setImage(avatar, for: .normal)
        titleLabel.text = withUser.fullname
        if withUser.isOnline {
            subTitleLabel.text = "Online"
        }else{
            subTitleLabel.text = "Ofline"
        }
    }
    
    func readTimeFrom(dateString: String) -> String{
        let date = dateFormatter().date(from: dateString)
        let currentDateFromatter = dateFormatter()
        currentDateFromatter.dateFormat = "HH:mm"
        
        return currentDateFromatter.string(from: date!)
    }
    
    
    // for attachment button
    func createAccessoryActionSheet(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let cameraAction = UIAlertAction(title: "Camera", style: .default) { (action) in
            self.openCamera()
        }
        
        let photoLibraryAction = UIAlertAction(title: "Photo Library", style: .default) { (action) in
            self.openPhotoLibrary()
        }
        
        let videoLibraryAction = UIAlertAction(title: "Video Library", style: .default) { (action) in
            self.openVideoLibrary()
        }
        
        let locationAction = UIAlertAction(title: "location", style: .default) { (action) in
            
            if   self.appDelegate.didHaveLocationAccess() {
                
                self.sendLocationMessage(location: self.appDelegate.coordinates!, date: Date())
            } else {
                print("please allow location access")
            }
            
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        
        cameraAction.setValue(UIImage(named: "camera"), forKey: "image")
        photoLibraryAction.setValue(UIImage(named: "picture"), forKey: "image")
        videoLibraryAction.setValue(UIImage(named: "video"), forKey: "image")
        locationAction.setValue(UIImage(named: "location"), forKey: "image")
        
        alert.addAction(cameraAction)
        alert.addAction(photoLibraryAction)
        alert.addAction(videoLibraryAction)
        alert.addAction(locationAction)
        alert.addAction(cancelAction)
        
        // present for ipad compatibility
        if (UI_USER_INTERFACE_IDIOM() == .pad ) {
            if let currentPopOverPresentaionController = alert.popoverPresentationController {
                currentPopOverPresentaionController.sourceView = self.inputToolbar.contentView.leftBarButtonItem
                currentPopOverPresentaionController.sourceRect = self.inputToolbar.contentView.leftBarButtonItem.bounds
                currentPopOverPresentaionController.permittedArrowDirections = .up
                
                self.present(alert, animated: true, completion: nil)
            }
           
        }
        //present for iphone
        else {
            self.present(alert, animated: true, completion: nil)

        }
    }
    
    func updateSendButton(isSend: Bool){
        
        if isSend {
            
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"send"), for: .normal)
            
        } else {
            
            self.inputToolbar.contentView.rightBarButtonItem.setImage(UIImage(named:"mic"), for: .normal)
        }
    }
    
    //MARK: ***** buttons action *****
    func openCamera(){
        
    }
    
    func openPhotoLibrary(){
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            camera.PresentPhotoLibrary(target: self, canEdit: false)
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { (newStatus) in
                if newStatus == PHAuthorizationStatus.authorized {
                    // Access is granted by user
                    self.camera.PresentPhotoLibrary(target: self, canEdit: false)

                }
            }
        default:
            print("Error: no access to photo album.")
        }
        
    }
    
    func openVideoLibrary(){
        
    }
    

    @objc func infoButtonTapped(){
        
    }
    
    @objc func callButtonTapped(){
        
    }
    
    @objc func showGroup(){
        
    }
    
    @objc func showContactDetails(){
        
        let VC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "contactDetailVC") as! ContactDetailsViewController
        
        VC.user = withUsers.first!
        navigationController?.pushViewController(VC, animated: true)
    }
    
    
    //MARK: avatar methods
    
    func getAvatarImages(){
        
        if showAvatar {
            
            collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize(width: 30, height: 30)
            collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize(width: 30, height: 30)
        }
        
        avatarImageFrom(user: currentUser!)
        
        for user in withUsers {
            avatarImageFrom(user: user)
        }
    }
    
    func avatarImageFrom(user: FUser) {
        if user.avatar != "" {
            
            dataImageFromString(pictureString: user.avatar) { ( imageData) in
                
                if imageData == nil {
                    return
                }
                
                if self.avatarImageDictionary != nil {
                    
                    self.avatarImageDictionary!.removeObject(forKey: user.objectId)
                    self.avatarImageDictionary!.setObject(imageData!, forKey: user.objectId as NSCopying)
                }else{
                    self.avatarImageDictionary = [user.objectId: imageData!]
                }
                
                self.createJSQAvatars(avatarDictionary: self.avatarImageDictionary)
            }
        }
    }
    
    func createJSQAvatars(avatarDictionary: NSMutableDictionary?){
        
        
        let defaultAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(named: "avatarPlaceholder"), diameter: 70)
        
        if avatarDictionary != nil {
            
            for userID in membersID {
               
                if let avatarImageData = avatarDictionary![userID] {
                    
                    let jsqAvatar = JSQMessagesAvatarImageFactory.avatarImage(with: UIImage(data: avatarImageData as! Data), diameter: 70)
                    
                    self.jsqAvatarDictionary!.setValue(jsqAvatar, forKey: userID)
                }else {
                    self.jsqAvatarDictionary!.setValue(defaultAvatar, forKey: userID)
                }
                
            }
            
            self.collectionView.reloadData()
        }
    }
    
}



//MARK:- message methods
extension ChatViewController {
    
    
    func loadMessage(){
        // get last 11 messages
        reference(.Message).document(currentUser!.objectId).collection(chatRoomID).order(by: kDATE, descending: true).limit(to: 11).getDocuments { (snapShot, error) in
            
            guard let snapShot = snapShot else {
                // initial loading is done
                self.initialLoadComplete = true
                //listen for new chats
                self.listenForNewChats()
                return
            }
            
            let sortedMessages = (dictionaryFromSnapshots(snapshots: snapShot.documents) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
            
            // remove corrupted messages
            self.loadedMessages =  self.removeCorrptedMessage(messages: sortedMessages)
            
            // convert messages to JSQmessages
            self.convertMessageToJSQMessage()
            self.finishReceivingMessage(animated: true)
            self.initialLoadComplete = true
           
            //TODO: get pictureMessages
            
            // get old messages in background
            self.loadOldMessagesInbackGround()
            // start listening to new chats
            self.listenForNewChats()
            
        
        }
    }
    
    func removeCorrptedMessage(messages:[NSDictionary]) -> [NSDictionary] {
        var tempMessages = messages
        
        for message in tempMessages {
            
            if message[kTYPE] != nil {
                if !legitTypes.contains(message[kTYPE] as! String) {
                    tempMessages.remove(at: tempMessages.index(of: message)!)
                }
            }else {
                tempMessages.remove(at: tempMessages.index(of: message)!)
            }
            
        }
        
        return tempMessages
    }
    
    func convertMessageToJSQMessage(){
        maxMessagesNumber = loadedMessages.count - displayedMessagesCount
        minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in minMessagesNumber ..< maxMessagesNumber {
            let messageDictionary = loadedMessages[i]
            
            returnConvertedMessage(messageDictionary: messageDictionary)
            displayedMessagesCount += 1
        }
        
        self.showLoadEarlierMessagesHeader = (displayedMessagesCount != loadedMessages.count)
    }
    
    func returnConvertedMessage(messageDictionary: NSDictionary) -> Bool {
        let incomingMessage = IncomingMessage(collectionView: self.collectionView!)
        
        if currentUser!.objectId == messageDictionary[kSENDERID] as! String {
            // update message status
        }
        
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomID)
        
        if message != nil {
            displayMessages.append(message!)
            dictionaryMessages.append(messageDictionary)
        }
        
        return isIncomingMessage(messageDictionary: messageDictionary)
    }
    
    func isIncomingMessage(messageDictionary: NSDictionary) -> Bool {
        
        if currentUser!.objectId == messageDictionary[kSENDERID] as! String {
            return false
        }else {
            return true
        }
    }
    
    func isIncomingMessage(message: JSQMessage) -> Bool {
        
        if currentUser!.objectId == message.senderId {
            return false
        }else {
            return true
        }
    }
    
    
    func listenForNewChats(){
        var lastMessageDate = "0"
        
        if loadedMessages.count > 0 {
            
            lastMessageDate = loadedMessages.last![kDATE] as! String
        }
        
        chatListener = reference(.Message).document(currentUser!.objectId).collection(chatRoomID).whereField(kDATE, isGreaterThan: lastMessageDate).addSnapshotListener({ (snapShot, error) in
            
            guard let snapShot = snapShot else { return }
            
            if !snapShot.isEmpty {
                
                for diff in snapShot.documentChanges {
                    
                    if diff.type == .added {
                        let item = diff.document.data() as NSDictionary
                        
                        if let type = item[kTYPE] {
                            
                            if self.legitTypes.contains(type as! String) {
                                
                                if type as! String == kPICTURE {
                                    // add to picture array
                                }
                                
                                if self.returnConvertedMessage(messageDictionary: item){
                                    JSQSystemSoundPlayer.jsq_playMessageReceivedAlert()
                                }
                                
                                self.finishReceivingMessage()
                            }
                        }
                    }
                }
            }
        })
        
    }
    
    //FIXME: should get data from fireSotre 10 by 10 not all of remaning messages at once
    func loadOldMessagesInbackGround(){
        if loadedMessages.count > 10 {
            let firstMessageDate = loadedMessages.first![kDATE] as! String
            
            reference(.Message).document(currentUser!.objectId).collection(chatRoomID).whereField(kDATE, isLessThan: firstMessageDate).getDocuments { (snapShot, error) in
                
                guard let snapShot = snapShot else { return }
                
               if !snapShot.isEmpty {
                
                    let sorted = ((dictionaryFromSnapshots(snapshots: snapShot.documents)) as NSArray).sortedArray(using: [NSSortDescriptor(key: kDATE, ascending: true)]) as! [NSDictionary]
                
                self.loadedMessages = self.removeCorrptedMessage(messages: sorted) + self.loadedMessages
                
                // get the picture Messages
                
                self.maxMessagesNumber = self.loadedMessages.count - self.displayedMessagesCount - 1
                self.minMessagesNumber = self.maxMessagesNumber - kNUMBEROFMESSAGES
                }
                
            }
            
        }
    }
    
    func loadMoreMessages(minNumber: Int, maxNumber: Int ){
        
        if loadOlderMessages {
            maxMessagesNumber = minNumber - 1
            minMessagesNumber = maxMessagesNumber - kNUMBEROFMESSAGES
        }
        
        if minMessagesNumber < 0 {
            minMessagesNumber = 0
        }
        
        for i in (minMessagesNumber ... maxMessagesNumber).reversed() {
            
            let message = loadedMessages[i]
            insertNewMessages(messageDictionary: message)
            displayedMessagesCount += 1
        }
        
        loadOlderMessages = true
        self.showLoadEarlierMessagesHeader = (displayedMessagesCount != loadedMessages.count)
        
        
    }
    
    func insertNewMessages(messageDictionary: NSDictionary){
        
        let incomingMessage = IncomingMessage(collectionView: self.collectionView)
        let message = incomingMessage.createMessage(messageDictionary: messageDictionary, chatRoomID: chatRoomID)
        
        dictionaryMessages.insert(messageDictionary, at: 0)
        displayMessages.insert(message!, at: 0 )
    }
    
    func sendTextMessage(text: String, date: Date){
        
        let outGoingMessage = OutGoingMessage(message: text, senderID: currentUser!.objectId, senderName: currentUser!.fullname, date: date, status: kDELIVERED, type: kTEXT)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        outGoingMessage.saveMessage(messageDictionary: outGoingMessage.messageDictionary, chatRoomID: chatRoomID, membersID: membersID, membersToPush: membersToPush)
        
    }
    
    func sendPhotoMessage(image: UIImage, date: Date){
        
        uploadImage(image: image, chatRoomID: chatRoomID, view: self.navigationController!.view) { (imageLink) in
            
            if imageLink != nil {
               
                let message = OutGoingMessage(message: "[" + kPICTURE + "]", pictureLink: imageLink!, senderID: self.currentUser!.objectId, senderName: self.currentUser!.fullname, date: date, status: kDELIVERED, type: kPICTURE)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                message.saveMessage(messageDictionary: message.messageDictionary, chatRoomID: self.chatRoomID, membersID: self.membersID, membersToPush: self.membersToPush)
            }
        }
    }
    
    func sendVideoMessage(video: NSURL?, date: Date){
        
    }
    
    
    
    // location message
    func sendLocationMessage(location: CLLocationCoordinate2D, date: Date){
        let lat = NSNumber(value: location.latitude)
        let long = NSNumber(value: location.longitude)

        let text = "[\(kLOCATION)]"
        
        let message = OutGoingMessage(message: text, latitude: lat, longitude: long, senderID: currentUser!.objectId, senderName: currentUser!.fullname, date: date, status: kDELIVERED, type: kLOCATION)
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        self.finishSendingMessage()
        
        message.saveMessage(messageDictionary: message.messageDictionary, chatRoomID: self.chatRoomID, membersID: self.membersID, membersToPush: self.membersToPush)
        
    }
    
    func sendAudioMessage(audio: String, date: Date){
        
        uploadAudio(audioPath: audio, chatRoomID: chatRoomID, view: self.navigationController!.view) { (audioPath) in
            
            if audioPath != nil {
                let message = OutGoingMessage(message: "[" + kAUDIO + "]" , audioLink: audioPath!, senderID: self.currentUser!.objectId, senderName: self.currentUser!.fullname, date: date, status: kDELIVERED, type: kAUDIO)
                
                JSQSystemSoundPlayer.jsq_playMessageSentSound()
                self.finishSendingMessage()
                
                message.saveMessage(messageDictionary: message.messageDictionary, chatRoomID: self.chatRoomID, membersID: self.membersID, membersToPush: self.membersToPush)
            }
        }
    }
    
    
}

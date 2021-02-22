//
//  ChatVC.swift
//  ClubAfib
//
//  Created by Fresh on 8/11/20.
//  Copyright © 2020 ETU. All rights reserved.
//

/*
 MIT License
 
 Copyright (c) 2017-2019 MessageKit
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

import UIKit
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift
import MessageKit
import InputBarAccessoryView
import SwiftyJSON

/// A base class for the example controllers
class ChatVC: MessagesViewController, MessagesDataSource {
    let primaryColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
    
    var isHistoryChat: Bool = false
    var isOpenedChat: Bool = false
    var userInfo: User!
    var doctorInfo: Doctor!
    
    var userAsChatClient: ChatUser!
    var userAsChatDoctor: ChatUser!
    
    var firebaseDB: Firestore!
    var chatRoomId = ""
    
    var messageList: [ChatMessage] = []
    var isFirstMessage = true
    var lastMessageDate: Timestamp?
    var loadMessageCount = 50
    
    let refreshControl = UIRefreshControl()
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter
    }()
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Show the navigation bar on other view controllers
        
        makeCustomNavigation()
        title = "Chat"
        
        self.setChatRoom()
        configureMessageCollectionView()
        configureMessageInputBar()
        
//        if !self.isOpenedChat {
//            self.showFeedBackAlert(isCloseAction: false)
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    func showFeedBackAlert(isCloseAction: Bool){
        let alert = AlertService()
        let reviewVC = alert.showReviewAlert() { (success, rating, reviewDesc) in
            if success {
                let doctorId = self.doctorInfo.userId
                let params: [String: Any] = [
                    "chat_id": self.chatRoomId,
                    "rating": rating,
                    "description": reviewDesc
                ]
                
                self.showLoadingProgress(view: self.view)
                
                ApiManager.sharedInstance.giveFeedBack(params: params, doctorId: doctorId){
                    data, error, status in
                    // Hide the loading progress
                    self.dismissLoadingProgress(view: self.view)
                    
                    if isCloseAction{
                        self.onBackPress()
                    }
                }
            } else {
                if isCloseAction{
                    self.onBackPress()
                }
            }
        }
        
        self.present(reviewVC, animated: false, completion: nil)
    }
    
    func makeCustomNavigation(){
        let imgBackArrow = UIImage(named: "ic_back")
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated:false)
        
        let attrs = [
            NSAttributedString.Key.foregroundColor: UIColor(red: 0, green: 35/255.0, blue: 99/255.0, alpha: 1.0),
            NSAttributedString.Key.font: UIFont(name: "Avenir Book", size: 20)!
        ]
        self.navigationController?.navigationBar.titleTextAttributes = attrs
        
        // Navigation Bar Shadow
        self.navigationController?.navigationBar.layer.masksToBounds = false
        self.navigationController?.navigationBar.layer.shadowColor = UIColor.black.cgColor
        self.navigationController?.navigationBar.layer.shadowOpacity = 0.2
        self.navigationController?.navigationBar.layer.shadowOffset = CGSize(width: 0, height: 2.0)
        self.navigationController?.navigationBar.layer.shadowRadius = 1
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(image: imgBackArrow, style: UIBarButtonItem.Style.plain, target: self, action: #selector(onBackPress))
        navigationItem.leftBarButtonItem?.tintColor = UIColor(red: 0, green: 35/255.0, blue: 99/255.0, alpha: 1.0)
        
        if self.isOpenedChat{
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Close", style: .plain, target: self, action: #selector(onCloseRoom))
            navigationItem.rightBarButtonItem?.tintColor = UIColor(red: 0, green: 35/255.0, blue: 99/255.0, alpha: 1.0)
        }
    }
    
    @objc func onBackPress(){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onCloseRoom(){
        let params: [String: String] = [
            "room_id": self.chatRoomId
        ]
        
        showLoadingProgress(view: self.navigationController?.view)
        
        ApiManager.sharedInstance.closeChatRoom(params: params){
            data, error, status in
            
            // Hide the loading progress
            self.dismissLoadingProgress(view: self.navigationController?.view)
            
            if status {
                self.isOpenedChat = false
                self.showFeedBackAlert(isCloseAction: true)
            } else {
                // Show the error message
                let errorMessage = error ?? "Something went wrong, try again later"
                self.showToast(message: errorMessage)
            }
        }
    }
    
    func setChatRoom(){
        // set firebase
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        self.firebaseDB = Firestore.firestore()
        
        if self.isHistoryChat{
            // Get Data current user info from api
            self.configChatUserData()
        } else {
            // Get Data current user info from api
            self.configChatUserData()
//            let params: [String: Int] = [
//                "doctor_id": self.doctorInfo.userId!
//            ]
//
//            showLoadingProgress(view: self.navigationController?.view)
//            
//            ApiManager.sharedInstance.getOrCreateChatRoom(params: params){
//                data, error, status in
//
//                // Hide the loading progress
//                self.dismissLoadingProgress(view: self.navigationController?.view)
//
//                if status{
//                    self.chatRoomId = data!["room_id"].stringValue
//
//                    // Get Data current user info from api
//                    self.configChatUserData()
//                } else {
//                    // Show the error message
//                    let errorMessage = error ?? "Something went wrong, try again later"
//                    self.showToast(message: errorMessage)
//                }
//            }
        }
    }
    
    func configChatUserData(){
        
        self.userAsChatClient = ChatUser(senderId: String(self.userInfo.userId), displayName: "", avatarImage: "")
        self.userAsChatDoctor = ChatUser(senderId: String(self.doctorInfo.userId), displayName: "", avatarImage: self.doctorInfo.imageUrl)

        self.checkIsEmptyMessage()
    }
    
    func checkIsEmptyMessage(){
        self.firebaseDB.collection("rooms").document(self.chatRoomId).collection("messages").addSnapshotListener{
            querySnapshot, error in
            
            guard let documents = querySnapshot?.documents else {
                print("Error fetching document: \(error!)")
                return
            }
            
            if documents.count != 0{
                self.isFirstMessage = false
                self.loadFirstMessages()
            }
        }
    }
    
    func getMessagesFromFirebase(){
        firebaseDB.collection("rooms").document(self.chatRoomId).collection("messages").order(by: "create_date", descending: true).limit(to: self.loadMessageCount)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var dbMessages: [ChatMessage] = []
                for document in documents{
                    let messageTxt = document.get("text") as! String
                    let user = ( document.get("sender") as! Int == self.userInfo.userId ) ? self.userAsChatClient : self.userAsChatDoctor
                    let messageId = document.documentID
                    let messageTimeStamp = document.get("create_date") as! Timestamp
                    let messageDate = messageTimeStamp.dateValue()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let messageShortDate = dateFormatter.date(from: dateFormatter.string(from: messageDate))!
                    self.lastMessageDate = messageTimeStamp
                    
                    let messageItem = ChatMessage(
                        text: messageTxt,
                        user: user!,
                        messageId: messageId,
                        date: messageShortDate
                    )
                    
                    dbMessages.insert(messageItem, at: 0)
                }
                
                self.isFirstMessage = false
                self.messageList = dbMessages
                self.messagesCollectionView.reloadData()
                self.messagesCollectionView.scrollToBottom(animated: false)
        }
    }
    
    func getMoreMessage(){
        let messageRef = firebaseDB.collection("rooms").document(self.chatRoomId).collection("messages")
        messageRef.order(by: "create_date", descending: true).whereField("create_date", isLessThan: self.lastMessageDate!).limit(to: self.loadMessageCount)
            .addSnapshotListener { querySnapshot, error in
                guard let documents = querySnapshot?.documents else {
                    print("Error fetching document: \(error!)")
                    return
                }
                
                var dbMessages: [ChatMessage] = []
                for document in documents{
                    let messageTxt = document.get("text") as! String
                    let user = ( document.get("sender") as! Int == self.userInfo.userId ) ? self.userAsChatClient : self.userAsChatDoctor
                    let messageId = document.documentID
                    let messageTimeStamp = document.get("create_date") as! Timestamp
                    let messageDate = messageTimeStamp.dateValue()
                    
                    let dateFormatter = DateFormatter()
                    dateFormatter.locale = Locale(identifier: "en_US_POSIX") // set locale to reliable US_POSIX
                    dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                    let messageShortDate = dateFormatter.date(from: dateFormatter.string(from: messageDate))!
                    self.lastMessageDate = messageTimeStamp
                    
                    let messageItem = ChatMessage(
                        text: messageTxt,
                        user: user!,
                        messageId: messageId,
                        date: messageShortDate
                    )
                    
                    dbMessages.insert(messageItem, at: 0)
                }
                
                self.messageList.insert(contentsOf: dbMessages, at: 0)
                self.messagesCollectionView.reloadDataAndKeepOffset()
                self.refreshControl.endRefreshing()
        }
    }
    
    func sendMessage(message: ChatMessage){
        let now = Timestamp(date: Date())
        
        var messageContent = ""
        var messageType = 0
        
        switch message.kind{
            case .text(let message):
                messageContent = message
                messageType = 0
                break
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .custom(_):
                break
            case .video(_):
                break
        }
        
        var messageRef: DocumentReference?
        messageRef = firebaseDB.collection("rooms").document(self.chatRoomId).collection("messages").addDocument(data: [
            "create_date": now,
            "sender": self.userInfo.userId,
            "text": messageContent,
            "type": messageType
        ]) { err in
            if let err = err {
                print("Error adding document: \(err)")
            } else {
                self.getMessagesFromFirebase()
                print("Document added with ID: \(messageRef!.documentID)")
            }
        }
    }
    
    func loadFirstMessages() {
        self.getMessagesFromFirebase()
    }
    
    @objc
    func loadMoreMessages() {
        if !self.isFirstMessage{
            self.getMoreMessage()
        } else {
            self.refreshControl.endRefreshing()
        }
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
    }
    
    func configureMessageInputBar() {
        if !self.isOpenedChat{
            messageInputBar.isHidden = true
        } else {
            messageInputBar.delegate = self
            messageInputBar.inputTextView.tintColor = primaryColor
            messageInputBar.sendButton.setTitle("", for: .normal)
            messageInputBar.sendButton.image = UIImage(named: "ic_send")
            messageInputBar.sendButton.tintColor = UIColor(red: 0, green: 35/255.0, blue: 99/255.0, alpha: 1.0)
            
            messageInputBar.layer.shadowColor = UIColor.black.cgColor
            messageInputBar.layer.shadowRadius = 4
            messageInputBar.layer.shadowOpacity = 0.3
            messageInputBar.layer.shadowOffset = CGSize(width: 0, height: 0)
            messageInputBar.separatorLine.isHidden = true
            
            messageInputBar.middleContentView!.layer.borderColor = UIColor(white: 0, alpha: 0.3).cgColor
            messageInputBar.middleContentView!.layer.borderWidth = 1
            messageInputBar.middleContentView!.layer.cornerRadius = 20
            messageInputBar.inputTextView.textContainerInset.left = 10
            messageInputBar.inputTextView.placeholderLabelInsets.left = 20
        }
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: ChatMessage) {
        self.sendMessage(message: message)
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        return self.userAsChatClient
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func cellBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        return NSAttributedString(string: "", attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let dateString = formatter.string(from: message.sentDate)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
    
}

// MARK: - MessageCellDelegate

extension ChatVC: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapImage(in cell: MessageCollectionViewCell) {
        print("Image tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapCellBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom cell label tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapPlayButton(in cell: AudioMessageCell) {
        print("Did play audio sound")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didStartAudio(in cell: AudioMessageCell) {
        print("Did start playing audio sound")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didPauseAudio(in cell: AudioMessageCell) {
        print("Did pause audio sound")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didStopAudio(in cell: AudioMessageCell) {
        print("Did stop audio sound")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
    
    func didTapBackground(in cell: MessageCollectionViewCell) {
        print("Background view tapped")
        messageInputBar.inputTextView.resignFirstResponder()
    }
}

// MARK: - MessageLabelDelegate

extension ChatVC: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
    func didSelectHashtag(_ hashtag: String) {
        print("Hashtag selected: \(hashtag)")
    }
    
    func didSelectMention(_ mention: String) {
        print("Mention selected: \(mention)")
    }
    
    func didSelectCustom(_ pattern: String, match: String?) {
        print("Custom data detector patter selected: \(pattern)")
    }
    
}

// MARK: - MessageInputBarDelegate

extension ChatVC: InputBarAccessoryViewDelegate {
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        
        // Here we can parse for which substrings were autocompleted
        let attributedText = messageInputBar.inputTextView.attributedText!
        let range = NSRange(location: 0, length: attributedText.length)
        attributedText.enumerateAttribute(.autocompleted, in: range, options: []) { (_, range, _) in
            
            let substring = attributedText.attributedSubstring(from: range)
            let context = substring.attribute(.autocompletedContext, at: 0, effectiveRange: nil)
            print("Autocompleted: `", substring, "` with context: ", context ?? [])
        }
        
        let components = inputBar.inputTextView.components
        messageInputBar.inputTextView.text = String()
        messageInputBar.invalidatePlugins()
        
        // Send button activity animation
        messageInputBar.sendButton.startAnimating()
        messageInputBar.inputTextView.placeholder = "Sending..."
        DispatchQueue.global(qos: .default).async {
            // fake send request task
            sleep(1)
            DispatchQueue.main.async { [weak self] in
                self?.messageInputBar.sendButton.stopAnimating()
                self?.messageInputBar.inputTextView.placeholder = "Aa"
                self?.insertMessages(components)
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        }
    }
    
    private func insertMessages(_ data: [Any]) {
        for component in data {
            let user = self.userAsChatClient
            if let str = component as? String {
                let message = ChatMessage(text: str, user: user!, messageId: UUID().uuidString, date: Date())
                insertMessage(message)
            }
        }
    }
}

extension ChatVC: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 18
    }
    
    func cellBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 0
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

extension ChatVC: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        switch detector {
        case .hashtag, .mention: return [.foregroundColor: UIColor.blue]
        default: return MessageLabel.defaultAttributes
        }
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation, .mention, .hashtag]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? primaryColor : UIColor(red: 230/255, green: 230/255, blue: 230/255, alpha: 1)
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        let tail: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubbleTail(tail, .curved)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.isHidden = true
        let imageURL = self.userAsChatDoctor.avatarImage
        if imageURL == nil || imageURL == ""{
            avatarView.image = UIImage(named: "default_avatar")
        } else {
            avatarView.sd_setImage(with: URL(string: imageURL!))
        }
        
        if(message.sender.senderId != String(self.userInfo.userId)){
            avatarView.isHidden = false
        }
    }
}


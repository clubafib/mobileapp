//
//  ChatHistoryVC.swift
//  ClubAfib
//
//  Created by Rener on 8/9/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import XLPagerTabStrip
import FirebaseCore
import FirebaseFirestore
import FirebaseFirestoreSwift

class ChatHistoryVC: UIViewController, IndicatorInfoProvider {

    var firebaseDB: Firestore!
    var rooms: [ChatRoom] = []
    
    @IBOutlet weak var roomTable: UITableView!
    @IBOutlet weak var emptyView: UIView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.emptyView.isHidden = true
        
        // set firebase
        let settings = FirestoreSettings()
        Firestore.firestore().settings = settings
        self.firebaseDB = Firestore.firestore()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.getRoomsList()
    }
    
    func getRoomsList(){
        if self.rooms.count == 0 {
            showLoadingProgress(view: self.view)
        }
        
        let userId = UserInfo.sharedInstance.userData.userId
        let roomsRef = self.firebaseDB.collection("rooms")
        roomsRef.order(by: "createdAt", descending: true).getDocuments() { (querySnapshot, err) in
            // Hide the loading progress
            self.dismissLoadingProgress(view: self.view)
            
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                self.rooms.removeAll()

                let group = DispatchGroup()
                for document in querySnapshot!.documents {
                    let data = document.data()
                    
                    if let roomUserId = data["user_id"] as? Int, roomUserId == userId {
                        let room = ChatRoom()
                        room.roomId = document.documentID
                        room.doctorId = data["doctor_id"] as? Int
                        room.userId = data["user_id"] as? Int
                        room.roomStatus = data["status"] as? Int
                        
                        for doctor in UserInfo.sharedInstance.doctorList{
                            if doctor.userId == room.doctorId{
                                room.doctorImageURL = doctor.imageUrl!
                                room.doctorFirstName = doctor.firstName
                                room.doctorLastName = doctor.lastName
                                room.doctorSubject = doctor.subject
                            }
                        }

                        group.enter()
                        // Get Last Message
                        document.reference.collection("messages").order(by: "create_date", descending: true).limit(to: 1).getDocuments() { querySnapshot, error in
                            guard let documents = querySnapshot?.documents else {
                                print("Error fetching document: \(error!)")
                                group.leave()
                                return
                            }
                            
                            var messageText = ""
                            if (documents.count != 0){
                                messageText = documents[0].get("text") as! String
                            }
                            
                            room.lastMessage = messageText
                            group.leave()
                        }

                        self.rooms.append(room)
                    }
                }
                // notify the main thread when all task are completed
                group.notify(queue: .main) {
                    self.roomTable.reloadData()
                    self.emptyView.isHidden = !self.rooms.isEmpty
                }
            }
        }
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
      return IndicatorInfo(title: "Chats")
    }

}

extension ChatHistoryVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.rooms.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "chat_history_viewcell", for: indexPath) as! ChatHistoryCell
        cell.setData(self.rooms[indexPath.row])
        cell.btnChat.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let roomInfo = self.rooms[indexPath.row]
        let chatVC = ChatVC()
        chatVC.userInfo = UserInfo.sharedInstance.userData
        for doctor in UserInfo.sharedInstance.doctorList{
            if doctor.userId == roomInfo.doctorId{
                chatVC.doctorInfo = doctor
            }
        }
        
        chatVC.chatRoomId = roomInfo.roomId
        chatVC.isHistoryChat = true
        chatVC.isOpenedChat = roomInfo.roomStatus != 1
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }

}

//
//  ContactsVC.swift
//  ClubAfib
//
//  Created by Rener on 7/25/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import SwiftyJSON
import XLPagerTabStrip

class ContactsVC: UIViewController, UITextFieldDelegate, IndicatorInfoProvider {
    
    @IBOutlet weak var tfSearch: UITextField!
    @IBOutlet weak var imgCancelSearch: UIImageView!
    @IBOutlet weak var tvContacts: UITableView!
    
    @IBOutlet weak var subscribeView: UIView!
    
    var contacts = [Doctor]()
    var filteredContacts = [Doctor]()
    
    var searchkey: String? = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        
        imgCancelSearch.isHidden = true
        tfSearch.addTarget(self, action: #selector(self.searchTextChange(_:)), for: .editingChanged)
        tfSearch.delegate = self
        imgCancelSearch.isUserInteractionEnabled = true
        imgCancelSearch.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.cancelSearchPressed(_:))))
        
        self.contacts = Array(Doctor.getDoctors())
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.getDoctorList()
        
        if UserInfo.sharedInstance.userPayment != nil {
            self.subscribeView.isHidden = true
        }
        else {
            self.subscribeView.isHidden = false
        }
        updateContacts()
    }
    
    func indicatorInfo(for pagerTabStripController: PagerTabStripViewController) -> IndicatorInfo {
        return IndicatorInfo(title: "Experts")
    }
    
    func getDoctorList(){
        if contacts.count == 0 {
            showLoadingProgress(view: self.view)
        }
        
        ApiManager.sharedInstance.getDoctorList(){
            doctors, errorMsg, status in
            
            // Hide the loading progress
            self.dismissLoadingProgress(view: self.view)
            
            if status, let doctors = doctors{
                self.contacts.removeAll()
                self.contacts.append(contentsOf: doctors)
                
                UserInfo.sharedInstance.doctorList = self.contacts
                self.updateContacts()
            } else {
                // Show the error message
                let errorMessage = errorMsg ?? "Something went wrong, try again later"
                self.showToast(message: errorMessage)
            }
        }
    }
    
    private func updateContacts() {
        filteredContacts = contacts.filter { contact in
            if searchkey == nil || searchkey!.isEmpty {
                return true
            }
            return "\(contact.firstName!) \(contact.lastName!)".contains(searchkey!) || contact.email?.contains(searchkey!) == true
        }
        tvContacts.reloadData()
    }
    
    private func gotoChat(_ doctor: Doctor, roomId: String) {
        let chatVC = ChatVC()
        chatVC.userInfo = UserInfo.sharedInstance.userData
        chatVC.doctorInfo = doctor
        chatVC.chatRoomId = roomId
        chatVC.isOpenedChat = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    
    @objc func searchTextChange(_ sender: Any) {
        searchkey = tfSearch.text
        imgCancelSearch.isHidden = searchkey == nil || searchkey!.isEmpty
        updateContacts()
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        return true
    }
    
    @objc func cancelSearchPressed(_ sender: Any) {
        searchkey = ""
        tfSearch.text = ""
        imgCancelSearch.isHidden = true
        
        updateContacts()
    }
    
    @IBAction func onSubscribeButtonTapped(_ sender: Any) {
        let subscriptionVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
        self.navigationController?.pushViewController(subscriptionVC, animated: true)
    }

    @IBAction func onChatWithDoctor(_ sender: UIButton) {
        let doctorIndex = sender.tag
        let doctor = self.filteredContacts[doctorIndex]
        
        
        if let payment = UserInfo.sharedInstance.userPayment {
            showLoadingProgress(view: self.navigationController?.view)
            
            let params: [String: Int] = [
                "doctor_id": doctor.userId
            ]
            ApiManager.sharedInstance.getOrCreateChatRoom(params: params){
                data, error, status in
                
                // Hide the loading progress
                self.dismissLoadingProgress(view: self.navigationController?.view)
                
                if payment.type == 0 {
                    ApiManager.sharedInstance.getGetActivePayments(complete: nil)
                }
                
                if let data = data {
                    let roomId = data["room_id"].stringValue
                    self.gotoChat(doctor, roomId: roomId)
                }
            }
        }
        else {
            let subscriptionVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
        }
    }
}

extension ContactsVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredContacts.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "contact_viewcell", for: indexPath) as! ContactViewCell
        cell.setData(filteredContacts[indexPath.row])
        cell.btnChat.tag = indexPath.row
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let doctorProfileVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "DoctorProfileVC") as! DoctorProfileVC
        doctorProfileVC.doctor = filteredContacts[indexPath.row]
        self.navigationController?.pushViewController(doctorProfileVC, animated: true)
    }

}

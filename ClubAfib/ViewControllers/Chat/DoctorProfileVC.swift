//
//  DoctorProfileVC.swift
//  ClubAfib
//
//  Created by Rener on 8/10/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import Cosmos

class DoctorProfileVC: UIViewController {

    @IBOutlet weak var imgAvatar: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblSubject: UILabel!
    @IBOutlet weak var rating: CosmosView!
    @IBOutlet weak var lblAbout: UILabel!
    @IBOutlet weak var lblAddress: UILabel!
    @IBOutlet weak var lblPhone: UILabel!
    @IBOutlet weak var lblNoFeedback: UILabel!
    @IBOutlet weak var tbFeedback: UITableView!
    @IBOutlet weak var tvFeedbackHeightConstraint: NSLayoutConstraint!
    
    var doctor: Doctor!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if doctor.imageUrl != nil && !doctor.imageUrl!.isEmpty
        {
            imgAvatar.sd_setImage(with: URL(string: doctor.imageUrl!))
        }
        else
        {
            imgAvatar.image = UIImage(named: "default_avatar")
        }
        lblName.text = "Dr. \(doctor.firstName!) \(doctor.lastName!)"
        lblSubject.text = doctor.subject
        rating.rating = doctor.rating   
        lblAbout.text = doctor.about
        lblAddress.text = doctor.address
        lblPhone.text = doctor.phone
        
        lblNoFeedback.text = doctor.feedbacks.count > 0 ? "" : "No Feedback".localized()
    }
    
    private func gotoChat(_ doctor: Doctor, roomId: String) {
        let chatVC = ChatVC()
        chatVC.userInfo = UserInfo.sharedInstance.userData
        chatVC.doctorInfo = doctor
        chatVC.chatRoomId = roomId
        chatVC.isOpenedChat = true
        
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    override func viewWillLayoutSubviews() {
        super.updateViewConstraints()
        self.tvFeedbackHeightConstraint?.constant = self.tbFeedback.contentSize.height
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

    @IBAction func onShareButtonPressed(_ sender: Any) {
        shareScreenshot()
    }

    @IBAction func onChatWithDoctor(_ sender: Any) {
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
                    self.gotoChat(self.doctor, roomId: roomId)
                }
                else {
                    print("Error on creat chat room: \(error ?? "")")
                    self.showToast(message: "There is an error on the server. Please try again later.")
                }
            }
        }
        else {
            let subscriptionVC = HOME_STORYBOARD.instantiateViewController(withIdentifier: "SubscriptionVC") as! SubscriptionVC
            self.navigationController?.pushViewController(subscriptionVC, animated: true)
        }
    }
}

extension DoctorProfileVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.doctor.feedbacks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "feedback_viewcell", for: indexPath) as! DoctorFeedbackViewCell
        cell.setData(doctor.feedbacks[indexPath.row])
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}


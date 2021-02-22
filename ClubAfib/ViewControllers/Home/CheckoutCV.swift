//
//  CheckoutCV.swift
//  ClubAfib
//
//  Created by Rener on 8/21/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import Stripe


class StripeAPIClient: NSObject, STPCustomerEphemeralKeyProvider {

    func createCustomerKey(withAPIVersion apiVersion: String, completion: @escaping STPJSONResponseCompletionBlock) {
        ApiManager.sharedInstance.getStripeEphemeralKeys(params: ["api_version": apiVersion]) { (data, error) in
            if let data = data {
                completion(data, nil)
            }
            else {
                completion(nil, error)
            }
        }
    }
}

class CheckoutCV: UIViewController {

    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblCard: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    
    @IBOutlet weak var btnPay: UIButton!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    let customerContext = STPCustomerContext(keyProvider: StripeAPIClient())
    var paymentContext: STPPaymentContext?
    
    var paymentMethod: STPPaymentMethod?
        
    var paymentInProgress: Bool = false {
        didSet {
            UIView.animate(withDuration: 0.3, delay: 0, options: .curveEaseIn, animations: {
                if self.paymentInProgress {
                    self.activityIndicator.startAnimating()
                    self.activityIndicator.alpha = 1
                    self.btnPay.alpha = 0
                } else {
                    self.activityIndicator.stopAnimating()
                    self.activityIndicator.alpha = 0
                    self.btnPay.alpha = 1
                }
            }, completion: nil)
        }
    }
    
    var type: Int = 0
    var price: Double!
    var subscriptionTitle: String!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.lblTitle.text = subscriptionTitle
        self.lblCard.text = ""
        self.lblPrice.text = String(format: "$%.2f", price)
        
        let facialTap = UITapGestureRecognizer(target: self, action: #selector(self.cardLabelTapped(_:)))
        self.lblCard.isUserInteractionEnabled = true
        self.lblCard.addGestureRecognizer(facialTap)
        
        self.paymentContext = STPPaymentContext(customerContext: customerContext)
        self.paymentContext?.delegate = self
        self.paymentContext?.hostViewController = self
        self.paymentContext?.paymentAmount = Int(price * 100)
    }
    
    private func oneTimePay(_ paymentId: String) {
        let params = [
            "stripe_id": paymentId
        ]
        ApiManager.sharedInstance.oneTimePay(params: params) { payment, error in
            if payment != nil {
                let alertController = UIAlertController(title: "Success", message: "Your purchase was successful!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default){(_: UIAlertAction) in
                    NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_SUBSCRIBED), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    private func subscribe(_ paymentId: String) {
        let params: [String: Any] = [
            "payment_id": paymentId,
            "type": self.type,
        ]
        ApiManager.sharedInstance.subscribe(params: params) { payment, error in
            if payment != nil {
                let alertController = UIAlertController(title: "Success", message: "Your purchase was successful!", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default){(_: UIAlertAction) in
                    NotificationCenter.default.post(name: Notification.Name(USER_NOTIFICATION_SUBSCRIBED), object: nil)
                    self.navigationController?.popViewController(animated: true)
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @objc func cardLabelTapped(_ sender: Any) {
        self.paymentContext?.presentPaymentOptionsViewController()
    }
    
    @IBAction func onPayButtonTapped(_ sender: Any) {
        if self.paymentContext?.paymentOptions != nil && self.paymentContext!.paymentOptions!.count > 0 {
            self.paymentInProgress = true
            self.paymentContext?.requestPayment()
        }
        else {
            self.paymentContext?.presentPaymentOptionsViewController()
        }
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension CheckoutCV: STPPaymentContextDelegate {
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFailToLoadWithError error: Error) {
        let alertController = UIAlertController(
            title: "Error",
            message: error.localizedDescription,
            preferredStyle: .alert
        )
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: { action in
            // Need to assign to _ because optional binding loses @discardableResult value
            // https://bugs.swift.org/browse/SR-1681
            _ = self.navigationController?.popViewController(animated: true)
        })
        let retry = UIAlertAction(title: "Retry", style: .default, handler: { action in
            self.paymentContext?.retryLoading()
        })
        alertController.addAction(cancel)
        alertController.addAction(retry)
        self.present(alertController, animated: true, completion: nil)
    }
    
    func paymentContextDidChange(_ paymentContext: STPPaymentContext) {
        if let paymentOption = paymentContext.selectedPaymentOption {
            self.lblCard.text = paymentOption.label
        } else {
            self.lblCard.text = "Select Payment"
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didCreatePaymentResult paymentResult: STPPaymentResult, completion: @escaping STPPaymentStatusBlock) {
        let params: [String : Any] = [
            "type": self.type,
        ]
        ApiManager.sharedInstance.getStripePaymentIntent(params: params) { (clientSecret, error) in
            if let clientSecret = clientSecret {
                self.paymentMethod = paymentResult.paymentMethod
                // Assemble the PaymentIntent parameters
                let paymentIntentParams = STPPaymentIntentParams(clientSecret: clientSecret)
                paymentIntentParams.paymentMethodId = paymentResult.paymentMethod.stripeId

                if self.type == 0 {

                    // Confirm the PaymentIntent
                    STPPaymentHandler.shared().confirmPayment(withParams: paymentIntentParams, authenticationContext: paymentContext) { status, paymentIntent, error in
                        switch status {
                        case .succeeded:
                            // Your backend asynchronously fulfills the customer's order, e.g. via webhook
                            completion(.success, nil)
                        case .failed:
                            completion(.error, error) // Report error
                        case .canceled:
                            completion(.userCancellation, nil) // Customer cancelled
                        @unknown default:
                            completion(.error, nil)
                        }
                    }
                }
                else {
                    self.subscribe(self.paymentMethod!.stripeId)
                }
            }
            else {
                completion(.error, error)
            }
        }
    }
    
    func paymentContext(_ paymentContext: STPPaymentContext, didFinishWith status: STPPaymentStatus, error: Error?) {
        self.paymentInProgress = false
        let title: String
        let message: String
        
        switch status {
        case .error:
            title = "Error"
            message = error?.localizedDescription ?? ""
            break
        case .success:
            return self.oneTimePay(self.paymentMethod!.stripeId)
        case .userCancellation:
            return // Do nothing
        @unknown default:
            return()
        }
        
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(action)
        self.present(alertController, animated: true, completion: nil)
    }
    
}

//
//  TermsVC.swift
//  ClubAfib
//
//  Created by Rener on 8/19/20.
//  Copyright © 2020 ETU. All rights reserved.
//

import UIKit
import WebKit

class TermsVC: UIViewController, WKNavigationDelegate {

    let termsURL = "https://clubafib.com/terms-and-conditions"
    
    @IBOutlet weak var webview: WKWebView!
    @IBOutlet weak var loader: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.webview.navigationDelegate = self
        self.loader.startAnimating()
        self.webview.load(NSURLRequest(url: NSURL(string: termsURL)! as URL) as URLRequest)
    }
    
    func webView(_ webView: WKWebView, didCommit navigation: WKNavigation!) {
        self.loader.startAnimating()
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.loader.stopAnimating()
        print("End loading")
    }
    
    @IBAction func onBackPressed(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }

}
